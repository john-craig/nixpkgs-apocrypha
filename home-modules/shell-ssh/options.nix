{ lib, pkgs, ... }:
{
  options.evak.shell.ssh = {
    enable = lib.mkEnableOption "portable SSH configuration";
    hosts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { ... }: {
            options = {
              hostname = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
              user = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
              port = lib.mkOption {
                type = lib.types.nullOr lib.types.port;
                default = null;
              };
              identityFile = lib.mkOption {
                type = lib.types.nullOr lib.types.path;
                default = null;
              };
              extraOptions = lib.mkOption {
                type = lib.types.attrsOf lib.types.str;
                default = { };
              };
              enabled = lib.mkOption {
                type = lib.types.bool;
                default = true;
              };
            };
          }
        )
      );
      default = { };
      description = "Explicit SSH host topology; hostname is required for enabled entries.";
    };
    agent = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.openssh;
      };
    };
    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };
    helperPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Explicit helper packages for specialized SSH entries.";
    };
  };
}
