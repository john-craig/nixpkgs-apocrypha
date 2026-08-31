{ config, lib, pkgs, ... }:
let
  cfg = config.evak.shell.development;
  packageFor = name: if pkgs ? ${name} then pkgs.${name} else null;
in
{
  options.evak.shell.development = {
    git = {
      enable = lib.mkEnableOption "Git";
      package = lib.mkOption { type = lib.types.nullOr lib.types.package; default = packageFor "git"; description = "Git package override."; };
      userName = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
      userEmail = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
      signingKey = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
      signCommits = lib.mkOption { type = lib.types.bool; default = false; };
      defaultBranch = lib.mkOption { type = lib.types.str; default = "main"; };
      preCommit = lib.mkOption { type = lib.types.bool; default = true; };
    };
    github = {
      enable = lib.mkEnableOption "GitHub CLI";
      package = lib.mkOption { type = lib.types.nullOr lib.types.package; default = packageFor "gh"; description = "GitHub CLI package override."; };
      hostsPath = lib.mkOption { type = lib.types.nullOr lib.types.path; default = null; description = "External gh hosts.yml file."; };
    };
    direnv = {
      enable = lib.mkEnableOption "direnv";
      package = lib.mkOption { type = lib.types.nullOr lib.types.package; default = packageFor "direnv"; };
      nixDirenv = lib.mkOption { type = lib.types.bool; default = true; };
    };
    nix = {
      enable = lib.mkEnableOption "portable Nix client tooling";
      package = lib.mkOption { type = lib.types.nullOr lib.types.package; default = packageFor "nix"; description = "Nix client package override."; };
      extraConfig = lib.mkOption { type = lib.types.lines; default = ""; description = "Portable per-user Nix configuration. Daemon and system settings do not belong here."; };
    };
  };

  config = {
    assertions = [
      { assertion = !cfg.git.enable || cfg.git.package != null; message = "evak.shell.development.git is enabled but Git is unavailable; set its package option."; }
      { assertion = !cfg.github.enable || cfg.github.package != null; message = "evak.shell.development.github is enabled but gh is unavailable; set its package option."; }
      { assertion = !cfg.direnv.enable || cfg.direnv.package != null; message = "evak.shell.development.direnv is enabled but direnv is unavailable; set its package option."; }
      { assertion = !cfg.nix.enable || cfg.nix.package != null; message = "evak.shell.development.nix is enabled but Nix is unavailable; set its package option."; }
    ];
    home.packages = lib.filter (p: p != null) (lib.optional cfg.git.enable cfg.git.package
      ++ lib.optional (cfg.git.enable && cfg.git.preCommit && packageFor "pre-commit" != null) (packageFor "pre-commit")
      ++ lib.optional cfg.github.enable cfg.github.package
      ++ lib.optional cfg.direnv.enable cfg.direnv.package
      ++ lib.optional (cfg.direnv.enable && cfg.direnv.nixDirenv && packageFor "nix-direnv" != null) (packageFor "nix-direnv")
      ++ lib.optional cfg.nix.enable cfg.nix.package);
    programs.git = lib.mkIf cfg.git.enable {
      enable = true;
      package = cfg.git.package;
      userName = cfg.git.userName;
      userEmail = cfg.git.userEmail;
      signing = lib.mkIf (cfg.git.signingKey != null) { key = cfg.git.signingKey; signByDefault = cfg.git.signCommits; };
      extraConfig = { init.defaultBranch = cfg.git.defaultBranch; };
    };
    programs.direnv = lib.mkIf cfg.direnv.enable { enable = true; package = cfg.direnv.package; nix-direnv.enable = cfg.direnv.nixDirenv; };
    home.file.".config/nix/nix.conf" = lib.mkIf (cfg.nix.enable && cfg.nix.extraConfig != "") { text = cfg.nix.extraConfig; };
    home.activation.githubHosts = lib.mkIf (cfg.github.enable && cfg.github.hostsPath != null) (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -r ${lib.escapeShellArg cfg.github.hostsPath} ]; then echo "GitHub hosts secret is not readable: ${cfg.github.hostsPath}" >&2; exit 1; fi
      install -m 0700 -d "$HOME/.config/gh"
      install -m 0600 ${lib.escapeShellArg cfg.github.hostsPath} "$HOME/.config/gh/hosts.yml"
    '');
  };
}
