{ config, lib, pkgs, ... }:
let
  cfg = config.evak.shell.restricted;
  quote = value: lib.escapeShellArg value;
  defaultPackage = if pkgs ? lshell then pkgs.lshell else null;
  package = if cfg.package != null then cfg.package else defaultPackage;
  configText = ''
    [global]
    allowed = ${quote (lib.concatStringsSep "," cfg.allowedCommands)}
    allowed_sudo = ${quote (lib.concatStringsSep "," cfg.allowedSudoCommands)}
    warning = ${quote cfg.warning}
    logpath = ${quote cfg.logPath}
    ssh = ${if cfg.ssh then "1" else "0"}
    forbidden = ${quote cfg.forbiddenCharacters}
    login_script = ${quote cfg.loginScript}
  '';
in
{
  options.evak.shell.restricted = {
    enable = lib.mkEnableOption "lshell restricted shell";
    package = lib.mkOption { type = lib.types.nullOr lib.types.package; default = defaultPackage; description = "lshell package override."; };
    allowedCommands = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "ls" "pwd" "exit" ]; };
    allowedSudoCommands = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ ]; };
    warning = lib.mkOption { type = lib.types.str; default = "*** You are in a restricted shell ***"; };
    logPath = lib.mkOption { type = lib.types.str; default = "~/.lshell/log"; };
    ssh = lib.mkOption { type = lib.types.bool; default = true; };
    forbiddenCharacters = lib.mkOption { type = lib.types.str; default = "&|<>"; };
    loginScript = lib.mkOption { type = lib.types.str; default = ""; };
  };
  config = {
    assertions = [{ assertion = !cfg.enable || package != null; message = "evak.shell.restricted is enabled but lshell is unavailable; set evak.shell.restricted.package."; }];
    home.packages = lib.mkIf cfg.enable (lib.filter (p: p != null) [ package ]);
    home.file.".config/lshell/lshell.conf" = lib.mkIf cfg.enable { text = configText; mode = "0600"; };
  };
}
