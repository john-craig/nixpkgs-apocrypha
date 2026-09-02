{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.evak.shell.cli.paru;
in
{
  options.evak.shell.cli.paru = {
    enable = lib.mkEnableOption "Paru AUR helper";
    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = if pkgs ? paru then pkgs.paru else null;
    };
  };
  config = {
    assertions = [
      {
        assertion = !cfg.enable || cfg.package != null;
        message = "evak.shell.cli.paru requires a package override.";
      }
    ];
    home.packages = lib.mkIf cfg.enable [ cfg.package ];
  };
}
