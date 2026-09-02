{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.evak.shell.development.nix;
in
{
  options.evak.shell.development.nix = {
    enable = lib.mkEnableOption "portable Nix client tooling";
    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = if pkgs ? nix then pkgs.nix else null;
      description = "Nix client package override.";
    };
    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Portable per-user Nix configuration. Daemon and system settings do not belong here.";
    };
  };
  config = {
    assertions = [
      {
        assertion = !cfg.enable || cfg.package != null;
        message = "evak.shell.development.nix is enabled but Nix is unavailable; set its package option.";
      }
    ];
    home.packages = lib.mkIf cfg.enable [ cfg.package ];
    home.file.".config/nix/nix.conf" = lib.mkIf (cfg.enable && cfg.extraConfig != "") {
      text = cfg.extraConfig;
    };
  };
}
