{ pkgs ? import <nixpkgs> { } }:
let
  eval = { enableZsh ? true, notifications ? false, historyMetadata ? false }:
    pkgs.lib.evalModules {
      specialArgs = { inherit pkgs; };
      modules = [
        ({ lib, ... }: {
          options = {
            home.homeDirectory = lib.mkOption {
              type = lib.types.path;
              default = "/home/evak";
            };
            home.file = lib.mkOption {
              type = lib.types.attrsOf (lib.types.submodule ({ lib, ... }: {
                options.source = lib.mkOption { type = lib.types.path; };
              }));
              default = { };
            };
            home.packages = lib.mkOption {
              type = lib.types.listOf lib.types.package;
              default = [ ];
            };
            home.sessionVariables = lib.mkOption {
              type = lib.types.attrsOf lib.types.str;
              default = { };
            };
            programs.zsh.enable = lib.mkOption {
              type = lib.types.bool;
              default = enableZsh;
            };
            programs.zsh.autosuggestion.enable = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
            programs.zsh.enableCompletion = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
            programs.zsh.syntaxHighlighting.enable = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
            programs.zsh.historySubstringSearch.enable = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
            programs.zsh.completionInit = lib.mkOption {
              type = lib.types.lines;
              default = "";
            };
            programs.zsh.initContent = lib.mkOption {
              type = lib.types.lines;
              default = "";
            };
            programs.zsh.shellAliases = lib.mkOption {
              type = lib.types.attrsOf lib.types.str;
              default = { };
            };
            programs.zsh.plugins = lib.mkOption {
              type = lib.types.listOf (lib.types.submodule ({ lib, ... }: {
                options = {
                  name = lib.mkOption { type = lib.types.str; };
                  src = lib.mkOption { type = lib.types.path; };
                  file = lib.mkOption { type = lib.types.str; default = ""; };
                };
              }));
              default = [ ];
            };
            programs.zsh.history = lib.mkOption {
              type = lib.types.submodule ({ lib, ... }: {
                options = {
                  path = lib.mkOption { type = lib.types.path; default = "/tmp/history"; };
                  size = lib.mkOption { type = lib.types.int; default = 0; };
                  save = lib.mkOption { type = lib.types.int; default = 0; };
                  ignoreDups = lib.mkOption { type = lib.types.bool; default = true; };
                  extended = lib.mkOption { type = lib.types.bool; default = false; };
                };
              });
              default = { };
            };
          };
          config = {
            evak.zsh.notifications.enable = notifications;
            evak.zsh.historyMetadata = historyMetadata;
          };
        })
        ./../home-modules/zsh
      ];
    };

  enabled = (eval { }).config;
  disabled = (eval { enableZsh = false; }).config;
  historyConfig = (eval { historyMetadata = true; }).config;
  notificationConfig = (eval { notifications = true; }).config;
  corePlugin = builtins.head enabled.programs.zsh.plugins;
in
assert enabled.programs.zsh.autosuggestion.enable;
assert enabled.programs.zsh.enableCompletion;
assert enabled.programs.zsh.syntaxHighlighting.enable;
assert enabled.programs.zsh.historySubstringSearch.enable;
assert builtins.match ".*autoload -Uz compinit.*" enabled.programs.zsh.completionInit != null;
assert enabled.programs.zsh.shellAliases == { };
assert corePlugin.name == "alpine-zsh-config";
assert corePlugin.file == "zshrc.d/50-key-bindings.zsh";
assert builtins.match ".*source /etc/environment.*" (builtins.readFile enabled.home.file.".zprofile".source) != null;
assert disabled.programs.zsh.autosuggestion.enable == false;
assert disabled.programs.zsh.enableCompletion == false;
assert disabled.programs.zsh.historySubstringSearch.enable == false;
assert disabled.programs.zsh.plugins == [ ];
assert disabled.home.file == { };
assert enabled.home.sessionVariables == { };
assert historyConfig.programs.zsh.history.path == "/home/evak/.zsh_history";
assert historyConfig.programs.zsh.history.extended;
assert builtins.length notificationConfig.programs.zsh.plugins == 2;
assert builtins.elem pkgs.curl notificationConfig.home.packages;
true
