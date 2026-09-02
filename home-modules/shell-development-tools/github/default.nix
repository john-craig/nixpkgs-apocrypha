{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.evak.shell.development.github;
in
{
  options.evak.shell.development.github = {
    enable = lib.mkEnableOption "GitHub CLI";
    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = if pkgs ? gh then pkgs.gh else null;
      description = "GitHub CLI package override.";
    };
    hostsPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "External gh hosts.yml file.";
    };
  };
  config = {
    assertions = [
      {
        assertion = !cfg.enable || cfg.package != null;
        message = "evak.shell.development.github is enabled but gh is unavailable; set its package option.";
      }
    ];
    home.packages = lib.mkIf cfg.enable [ cfg.package ];
    home.activation.githubHosts = lib.mkIf (cfg.enable && cfg.hostsPath != null) {
      after = [ "writeBoundary" ];
      data = ''
        if [ ! -r ${lib.escapeShellArg cfg.hostsPath} ]; then echo "GitHub hosts secret is not readable: ${cfg.hostsPath}" >&2; exit 1; fi
        install -m 0700 -d "$HOME/.config/gh"
        install -m 0600 ${lib.escapeShellArg cfg.hostsPath} "$HOME/.config/gh/hosts.yml"
      '';
    };
  };
}
