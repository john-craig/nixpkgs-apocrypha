{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.evak.shell.cli.instagram;
in
{
  options.evak.shell.cli.instagram = {
    enable = lib.mkEnableOption "Instagram CLI";
    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = if pkgs ? instagram-cli then pkgs.instagram-cli else null;
      description = "Instagram CLI package override.";
    };
  };
  config = {
    assertions = [
      {
        assertion = !cfg.enable || cfg.package != null;
        message = "evak.shell.cli.instagram requires a package override.";
      }
    ];
    home.packages = lib.mkIf cfg.enable [ cfg.package ];
  };
}
