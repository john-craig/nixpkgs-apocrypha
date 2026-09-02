{ pkgs ? import <nixpkgs> { } }:
pkgs.testers.nixosTest {
  name = "apocrypha-traefik-jit-access";
  nodes.machine = {
    imports = [ ../nixos-modules/traefik-jit-access.nix ];
    system.stateVersion = "24.11";
    environment.systemPackages = [ pkgs.jq pkgs.curl ];
    services.traefik.enable = true;
    services.traefik.dynamicConfigOptions.http = {
      routers.protected = {
        entryPoints = [ "http" ];
        rule = "Host(`protected.test`) && ClientIP(`10.0.0.0/8`)";
        service = "protected";
      };
      services.protected.loadBalancer.servers = [ { url = "http://127.0.0.1:18080"; } ];
    };
    services.apocrypha.traefikJitAccess = {
      enable = true;
      apiEndpoint = "http://127.0.0.1:18081";
      ruleFragmentsToStrip = [ "ClientIP(`10.0.0.0/8`)" ];
    };
    systemd.services.router-api = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.python3}/bin/python ${pkgs.writeText "router-api.py" ''
          import json
          from http.server import BaseHTTPRequestHandler, HTTPServer
          class Handler(BaseHTTPRequestHandler):
              def do_GET(self):
                  self.send_response(200)
                  self.send_header("Content-Type", "application/json")
                  self.end_headers()
                  self.wfile.write(json.dumps([{"name": "protected", "rule": "Host(`protected.test`) && ClientIP(`10.0.0.0/8`)", "service": "protected", "entryPoints": ["http"]}]).encode())
              def log_message(self, *_): pass
          HTTPServer(("127.0.0.1", 18081), Handler).serve_forever()
        ''}";
        DynamicUser = true;
      };
    };
    systemd.services.protected = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.python3}/bin/python -m http.server 18080 --bind 127.0.0.1 --directory ${pkgs.writeTextDir "index.html" "jit backend"}";
        DynamicUser = true;
      };
    };
  };
  testScript = ''
    machine.wait_for_unit("router-api.service")
    machine.wait_for_unit("traefik.service")
    machine.succeed("test \"$(curl --silent --output /dev/null --write-out '%{http_code}' -H 'Host: protected.test' http://127.0.0.1/)\" != 200")
    machine.succeed("traefik-jit-access grant --ip 0.0.0.0/0 --duration 2s protected.test")
    machine.succeed("jq -e '.http.routers | length == 1' /var/lib/traefik/dynamic/jit-access/protected-test.json")
    machine.succeed("traefik-jit-access revoke protected.test")
    machine.succeed("test ! -e /var/lib/traefik/dynamic/jit-access/protected-test.json")
    machine.succeed("traefik-jit-access grant --ip 0.0.0.0/0 --duration 1s protected.test")
    machine.sleep(2)
    machine.succeed("traefik-jit-access prune")
    machine.succeed("test ! -e /var/lib/traefik-jit-access/grants/protected-test.json")
    machine.succeed("systemctl is-enabled traefik-jit-access-prune.timer")
    machine.succeed("test \"$(stat -c %a /var/lib/traefik-jit-access)\" = 750")
  '';
}
