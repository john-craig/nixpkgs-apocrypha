{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.evak.shell.cli.tea;
in
{
  options.evak.shell.cli.tea = {
    enable = lib.mkEnableOption "Tea Gitea CLI";
    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = if pkgs ? tea then pkgs.tea else null;
    };
  };
  config = {
    assertions = [
      {
        assertion = !cfg.enable || cfg.package != null;
        message = "evak.shell.cli.tea requires a package override.";
      }
    ];
    home.packages = lib.mkIf cfg.enable [ cfg.package ];
  };
}
