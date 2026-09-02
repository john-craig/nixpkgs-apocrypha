{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.evak.shell.cli.dismas;
in
{
  options.evak.shell.cli.dismas = {
    enable = lib.mkEnableOption "Dismas CLI";
    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = if pkgs ? dismas then pkgs.dismas else null;
    };
  };
  config = {
    assertions = [
      {
        assertion = !cfg.enable || cfg.package != null;
        message = "evak.shell.cli.dismas requires a package override.";
      }
    ];
    home.packages = lib.mkIf cfg.enable [ cfg.package ];
  };
}
