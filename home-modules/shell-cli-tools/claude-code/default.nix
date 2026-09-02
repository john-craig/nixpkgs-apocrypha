{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.evak.shell.cli.claudeCode;
in
{
  options.evak.shell.cli.claudeCode = {
    enable = lib.mkEnableOption "Claude Code CLI";
    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = if pkgs ? claude-code then pkgs.claude-code else null;
    };
  };
  config = {
    assertions = [
      {
        assertion = !cfg.enable || cfg.package != null;
        message = "evak.shell.cli.claudeCode requires a package override.";
      }
    ];
    home.packages = lib.mkIf cfg.enable [ cfg.package ];
  };
}
