{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.evak.shell.development.direnv;
in
{
  options.evak.shell.development.direnv = {
    enable = lib.mkEnableOption "direnv";
    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = if pkgs ? direnv then pkgs.direnv else null;
    };
    nixDirenv = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };
  config = {
    assertions = [
      {
        assertion = !cfg.enable || cfg.package != null;
        message = "evak.shell.development.direnv is enabled but direnv is unavailable; set its package option.";
      }
    ];
    home.packages = lib.mkIf cfg.enable (
      lib.filter (p: p != null) (
        [ cfg.package ] ++ lib.optional (cfg.nixDirenv && pkgs ? nix-direnv) pkgs.nix-direnv
      )
    );
    programs.direnv = lib.mkIf cfg.enable {
      enable = true;
      package = cfg.package;
      nix-direnv.enable = cfg.nixDirenv;
    };
  };
}
