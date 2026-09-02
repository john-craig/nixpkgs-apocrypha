{ pkgs ? import <nixpkgs> { } }:
pkgs.testers.nixosTest {
  name = "apocrypha-traefik-routes";
  nodes.machine = {
    imports = [ ../nixos-modules/traefik.nix ../nixos-modules/reverse-proxy.nix ];
    system.stateVersion = "24.11";
    networking.firewall.enable = false;
    services.apocrypha.traefik = {
      enable = true;
      httpAddress = ":8080";
      httpsAddress = ":8443";
      logDirectory = "/var/lib/traefik";
      enableHttpRedirect = false;
      resolverName = "test";
      containers = { enable = true; networkName = "apocrypha-proxy"; };
      staticConfiguration = {
        log.filePath = pkgs.lib.mkForce "";
        accessLog.filePath = pkgs.lib.mkForce "";
      };
    };
    services.apocrypha.reverseProxy = {
      enable = true;
      routes.public = {
        hostname = "public.test";
        upstream = "http://127.0.0.1:18080";
        entryPoints = [ "web" ];
      };
    };
    systemd.services.backend = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.python3}/bin/python -m http.server 18080 --bind 127.0.0.1 --directory ${pkgs.writeTextDir "index.html" "route backend"}";
        DynamicUser = true;
      };
    };
  };
  testScript = ''
    machine.wait_for_unit("traefik.service")
    machine.wait_for_open_port(8080)
    machine.succeed("systemctl start traefik-proxy-network.service")
    machine.succeed("podman network inspect apocrypha-proxy")
    machine.wait_until_succeeds("curl --fail --silent --show-error --location --insecure -H 'Host: public.test' http://127.0.0.1:8080/ | grep -q 'route backend'", timeout=60)
  '';
}
