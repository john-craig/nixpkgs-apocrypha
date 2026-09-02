{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.evak.shell.development.git;
  packageFor = name: if pkgs ? ${name} then pkgs.${name} else null;
in
{
  options.evak.shell.development.git = {
    enable = lib.mkEnableOption "Git";
    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = packageFor "git";
      description = "Git package override.";
    };
    userName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    userEmail = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    signingKey = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    signCommits = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    defaultBranch = lib.mkOption {
      type = lib.types.str;
      default = "main";
    };
    preCommit = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };
  config = {
    assertions = [
      {
        assertion = !cfg.enable || cfg.package != null;
        message = "evak.shell.development.git is enabled but Git is unavailable; set its package option.";
      }
    ];
    home.packages = lib.mkIf cfg.enable (
      lib.filter (p: p != null) (
        [ cfg.package ]
        ++ lib.optional (cfg.preCommit && packageFor "pre-commit" != null) (packageFor "pre-commit")
      )
    );
    programs.git = lib.mkIf cfg.enable {
      enable = true;
      package = cfg.package;
      userName = cfg.userName;
      userEmail = cfg.userEmail;
      signing = lib.mkIf (cfg.signingKey != null) {
        key = cfg.signingKey;
        signByDefault = cfg.signCommits;
      };
      extraConfig = {
        init.defaultBranch = cfg.defaultBranch;
      };
    };
  };
}
