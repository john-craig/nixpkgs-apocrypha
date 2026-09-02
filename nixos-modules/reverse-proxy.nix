{ config, lib, ... }:
let
  cfg = config.services.apocrypha.reverseProxy;
  routeType = lib.types.submodule ({ name, ... }: {
    options = {
      enable = lib.mkEnableOption "this reverse-proxy route" // { default = true; };
      hostname = lib.mkOption { type = lib.types.str; default = ""; };
      upstream = lib.mkOption { type = lib.types.str; default = ""; };
      accessClass = lib.mkOption {
        type = lib.types.enum [ "public" "internal" "external" ];
        default = "public";
      };
      entryPoints = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "websecure" ]; };
      tlsResolver = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
      priority = lib.mkOption { type = lib.types.int; default = 0; };
      pathPrefix = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
      middlewares = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ ]; };
      containerNetwork = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
    };
  });
  routeRule = route:
    "Host(`${route.hostname}`)"
    + lib.optionalString (route.pathPrefix != null) " && PathPrefix(`${route.pathPrefix}`)"
    + lib.optionalString (route.accessClass == "internal") " && ${cfg.internalRule}";
  routeName = name: "apocrypha-${name}";
  enabledRoutes = lib.filterAttrs (_: route: route.enable) cfg.routes;
  routeAssertions = lib.flatten (lib.mapAttrsToList (name: route: [
    { assertion = route.hostname != ""; message = "reverse-proxy route ${name} must set hostname."; }
    { assertion = route.upstream != ""; message = "reverse-proxy route ${name} must set upstream."; }
    { assertion = route.tlsResolver != null || !(builtins.elem "websecure" route.entryPoints); message = "reverse-proxy route ${name} must set tlsResolver when using websecure."; }
  ]) enabledRoutes);
  routers = lib.mapAttrs' (name: route: lib.nameValuePair (routeName name) ({
    entryPoints = route.entryPoints;
    rule = routeRule route;
    priority = route.priority;
    service = routeName name;
    middlewares = route.middlewares ++ lib.optional (route.accessClass == "external" && cfg.externalMiddleware != null) cfg.externalMiddleware;
  } // lib.optionalAttrs (route.tlsResolver != null) { tls.certResolver = route.tlsResolver; })) enabledRoutes;
  services = lib.mapAttrs' (name: route: lib.nameValuePair (routeName name) {
    loadBalancer.servers = [ { url = route.upstream; } ];
  }) enabledRoutes;
in
{
  options.services.apocrypha.reverseProxy = {
    enable = lib.mkEnableOption "structured Traefik reverse-proxy routes";
    internalRule = lib.mkOption { type = lib.types.str; default = "ClientIP(`127.0.0.1/32`)"; };
    externalMiddleware = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
    proxyNetwork = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
    routes = lib.mkOption { type = lib.types.attrsOf routeType; default = { }; };
  };

  config = lib.mkIf cfg.enable {
    assertions = routeAssertions ++ lib.optional (cfg.internalRule == "") {
      assertion = false;
      message = "services.apocrypha.reverseProxy.internalRule must not be empty when reverse proxy is enabled.";
    };
    services.traefik.dynamicConfigOptions.http = {
      routers = routers;
      services = services;
    };
  };
}
