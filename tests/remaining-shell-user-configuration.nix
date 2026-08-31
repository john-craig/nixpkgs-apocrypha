{ pkgs ? import <nixpkgs> { } }:
let
  lib = pkgs.lib // { hm.dag.entryAfter = _:_; };
  base = {
    options = {
      home.homeDirectory = lib.mkOption { type = lib.types.path; default = "/home/test"; };
      home.packages = lib.mkOption { type = lib.types.listOf lib.types.package; default = [ ]; };
      home.file = lib.mkOption { type = lib.types.attrsOf (lib.types.submodule ({ ... }: { options = { text = lib.mkOption { type = lib.types.nullOr lib.types.lines; default = null; }; mode = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; }; }; })); default = { }; };
      home.activation = lib.mkOption { type = lib.types.attrsOf lib.types.anything; default = { }; };
      assertions = lib.mkOption { type = lib.types.listOf lib.types.anything; default = [ ]; };
      programs.ssh.enable = lib.mkOption { type = lib.types.bool; default = false; };
      programs.ssh.matchBlocks = lib.mkOption { type = lib.types.attrs; default = { }; };
      programs.ssh.extraConfig = lib.mkOption { type = lib.types.lines; default = ""; };
      programs.zsh.initContent = lib.mkOption { type = lib.types.lines; default = ""; };
      programs.git.enable = lib.mkOption { type = lib.types.bool; default = false; };
      programs.git.package = lib.mkOption { type = lib.types.nullOr lib.types.package; default = null; };
      programs.git.userName = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
      programs.git.userEmail = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
      programs.git.signing = lib.mkOption { type = lib.types.attrs; default = { }; };
      programs.git.extraConfig = lib.mkOption { type = lib.types.attrs; default = { }; };
      programs.direnv.enable = lib.mkOption { type = lib.types.bool; default = false; };
      programs.direnv.package = lib.mkOption { type = lib.types.nullOr lib.types.package; default = null; };
      programs.direnv.nix-direnv.enable = lib.mkOption { type = lib.types.bool; default = false; };
      services.ssh-agent.enable = lib.mkOption { type = lib.types.bool; default = false; };
      services.ssh-agent.package = lib.mkOption { type = lib.types.package; default = pkgs.openssh; };
    };
  };
  eval = module: extra: (lib.evalModules { specialArgs = { inherit pkgs lib; }; modules = [ base extra module ]; }).config;
  cliDisabled = eval ./../home-modules/shell-cli-tools { };
  cliEnabled = eval ./../home-modules/shell-cli-tools { evak.shell.cli.tea.enable = true; };
  devEnabled = eval ./../home-modules/shell-development-tools { evak.shell.development.nix.enable = true; };
  sshEnabled = eval ./../home-modules/shell-ssh { evak.shell.ssh = { enable = true; hosts = { example = { hostname = "example.test"; }; }; }; };
  restrictedEnabled = eval ./../home-modules/restricted-shell { evak.shell.restricted = { enable = true; package = pkgs.hello; allowedCommands = [ "ls" "printf 'a b'" ]; }; };
  exports = import ./../home-modules;
in
pkgs.runCommand (assert cliDisabled.home.packages == [ ];
  assert cliEnabled.home.packages == [ pkgs.tea ];
  assert builtins.length devEnabled.home.packages == 1;
  assert (builtins.head devEnabled.home.packages).pname == "nix";
  assert sshEnabled.programs.ssh.matchBlocks.example.hostname == "example.test";
  assert builtins.match ".*printf.*" restrictedEnabled.home.file.".config/lshell/lshell.conf".text != null;
  assert exports.alucard == exports.shellCliTools;
  assert exports.git == exports.shellDevelopmentTools;
  assert exports.ssh == exports.shellSsh;
  assert exports.lshell == exports.restrictedShell;
  "remaining-shell-user-configuration-test") { } "touch $out"
