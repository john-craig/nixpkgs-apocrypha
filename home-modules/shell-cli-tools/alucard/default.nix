{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.evak.shell.cli.alucard;
  package = if pkgs ? alucard then pkgs.alucard else null;
in
{
  options.evak.shell.cli.alucard = {
    enable = lib.mkEnableOption "Alucard deployment CLI";
    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = package;
      description = "Alucard package override.";
    };
    repositoryPath = lib.mkOption {
      type = lib.types.path;
      default = "${config.home.homeDirectory}/src/alucard";
    };
    hostConfig = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Alucard host configuration.";
    };
  };
  config = {
    assertions = [
      {
        assertion = !cfg.enable || cfg.package != null;
        message = "evak.shell.cli.alucard is enabled, but its package is unavailable; set evak.shell.cli.alucard.package.";
      }
    ];
    home.packages = lib.mkIf cfg.enable [ cfg.package ];
    home.file.".config/alucard/hosts.nix" = lib.mkIf cfg.enable {
      text = builtins.toJSON cfg.hostConfig;
    };
    programs.zsh.initContent = lib.mkIf cfg.enable ''
      if [[ -r ${lib.escapeShellArg "${cfg.repositoryPath}/completions/alucard.zsh"} ]]; then
        source ${lib.escapeShellArg "${cfg.repositoryPath}/completions/alucard.zsh"}
      fi
    '';
  };
}
