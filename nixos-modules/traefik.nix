{ config, lib, pkgs, ... }:
let
  cfg = config.services.apocrypha.traefik;
  containerCfg = cfg.containers;
in
{
  options.services.apocrypha.traefik = {
    enable = lib.mkEnableOption "the repository Traefik service configuration";

    dataDirectory = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/traefik";
      description = "Persistent Traefik data directory.";
    };

    resolverName = lib.mkOption {
      type = lib.types.str;
      default = "letsencrypt";
    };

    dnsProvider = lib.mkOption {
      type = lib.types.str;
      default = "cloudflare";
    };

    dnsCredentialsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "External environment file containing DNS provider credentials.";
    };

    logDirectory = lib.mkOption {
      type = lib.types.path;
      default = "/var/log/traefik";
    };

    logLevel = lib.mkOption {
      type = lib.types.str;
      default = "INFO";
    };

    httpEntryPoint = lib.mkOption {
      type = lib.types.str;
      default = "web";
    };

    httpsEntryPoint = lib.mkOption {
      type = lib.types.str;
      default = "websecure";
    };

    httpAddress = lib.mkOption {
      type = lib.types.str;
      default = ":80";
    };

    httpsAddress = lib.mkOption {
      type = lib.types.str;
      default = ":443";
    };

    enableHttpRedirect = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Redirect requests from the HTTP entry point to HTTPS.";
    };

    trustedForwardedHeaders = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    trustedProxyProtocol = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    staticConfiguration = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };

    dynamicConfiguration = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };

    containers = {
      enable = lib.mkEnableOption "Traefik container-provider integration";

      socketPath = lib.mkOption {
        type = lib.types.path;
        default = "/var/run/podman/podman.sock";
      };

      networkName = lib.mkOption {
        type = lib.types.str;
        default = "";
      };

      exposedByDefault = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = lib.optional (cfg.containers.enable && containerCfg.networkName == "") {
      assertion = false;
      message = "services.apocrypha.traefik.containers.networkName must be set when container integration is enabled.";
    };

    services.traefik = {
      enable = true;
      dataDir = cfg.dataDirectory;
      environmentFiles = lib.optional (cfg.dnsCredentialsFile != null) cfg.dnsCredentialsFile;
      staticConfigOptions = lib.mkMerge [
        {
          log = { level = cfg.logLevel; };
          log.filePath = "${cfg.logDirectory}/traefik.log";
          accessLog.filePath = "${cfg.logDirectory}/access.log";
          entryPoints.${cfg.httpEntryPoint} = {
            address = cfg.httpAddress;
          } // lib.optionalAttrs cfg.enableHttpRedirect {
            http.redirections.entryPoint = {
              to = cfg.httpsEntryPoint;
              scheme = "https";
            };
          };
          entryPoints.${cfg.httpsEntryPoint} = {
            address = cfg.httpsAddress;
            forwardedHeaders = {
              insecure = false;
              trustedIPs = cfg.trustedForwardedHeaders;
            };
          } // lib.optionalAttrs (cfg.trustedProxyProtocol != [ ]) {
            proxyProtocol.trustedIPs = cfg.trustedProxyProtocol;
          };
        }
        (lib.optionalAttrs (cfg.dnsCredentialsFile != null) {
          certificatesResolvers.${cfg.resolverName}.acme = {
            storage = "${cfg.dataDirectory}/acme.json";
            dnsChallenge.provider = cfg.dnsProvider;
          };
        })
        cfg.staticConfiguration
        (lib.mkIf containerCfg.enable {
          providers.docker = {
            endpoint = "unix://${containerCfg.socketPath}";
            exposedByDefault = containerCfg.exposedByDefault;
            network = containerCfg.networkName;
          };
        })
      ];
      dynamicConfigOptions = lib.mkMerge [ cfg.dynamicConfiguration ];
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.logDirectory} 0750 traefik traefik - -"
    ] ++ lib.optionals containerCfg.enable [
      "A ${containerCfg.socketPath} - - - - user:traefik:rwx"
    ];

    systemd.services.traefik = {
      serviceConfig.ReadWritePaths = [ cfg.logDirectory ];
    } // lib.optionalAttrs containerCfg.enable {
      after = [ "systemd-tmpfiles-setup.service" ];
      wants = [ "systemd-tmpfiles-setup.service" ];
      serviceConfig.SupplementaryGroups = [ "podman" ];
    };

    virtualisation.podman.enable = lib.mkIf containerCfg.enable true;
    systemd.services.traefik-proxy-network = lib.mkIf containerCfg.enable {
      description = "Create the Traefik proxy network";
      wantedBy = [ "multi-user.target" ];
      before = [ "traefik.service" ];
      path = [ pkgs.podman ];
      serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
      script = ''
        podman network inspect ${lib.escapeShellArg containerCfg.networkName} >/dev/null 2>&1 || \
          podman network create ${lib.escapeShellArg containerCfg.networkName}
      '';
    };
  };
}
