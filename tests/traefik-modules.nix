{ pkgs ? import <nixpkgs> { } }:
let
  eval = modules: import "${pkgs.path}/nixos/lib/eval-config.nix" {
    system = "x86_64-linux";
    inherit modules;
  };
  disabled = eval [ ../nixos-modules/traefik.nix ../nixos-modules/reverse-proxy.nix ];
  enabled = eval [
    ../nixos-modules/traefik.nix
    ../nixos-modules/reverse-proxy.nix
    {
      system.stateVersion = "24.11";
      services.apocrypha.traefik = {
        enable = true;
        resolverName = "test-resolver";
        dnsCredentialsFile = "/run/secrets/dns.env";
      };
      services.apocrypha.reverseProxy = {
        enable = true;
        internalRule = "ClientIP(`10.0.0.0/8`)";
        externalMiddleware = "auth@file";
        routes = {
          internal = {
            hostname = "internal.example";
            upstream = "http://127.0.0.1:8000";
            accessClass = "internal";
            tlsResolver = "test-resolver";
          };
          external = {
            hostname = "external.example";
            upstream = "http://127.0.0.1:8001";
            accessClass = "external";
            tlsResolver = "test-resolver";
          };
        };
      };
    }
  ];
  incomplete = eval [
    ../nixos-modules/reverse-proxy.nix
    { services.apocrypha.reverseProxy = { enable = true; routes.bad = { }; }; }
  ];
  messages = map (assertion: assertion.message) incomplete.config.assertions;
in
pkgs.runCommand "apocrypha-traefik-module-evaluation" { }
  (assert disabled.config.services.traefik.enable == false;
   assert enabled.config.services.traefik.enable;
   assert enabled.config.services.traefik.environmentFiles == [ "/run/secrets/dns.env" ];
   assert !(enabled.config.services.traefik.staticConfigOptions ? providers);
   assert enabled.config.services.traefik.dynamicConfigOptions.http.routers.apocrypha-internal.rule == "Host(`internal.example`) && ClientIP(`10.0.0.0/8`)";
   assert builtins.elem "reverse-proxy route bad must set hostname." messages;
   assert builtins.elem "reverse-proxy route bad must set upstream." messages;
   ''touch $out'')
