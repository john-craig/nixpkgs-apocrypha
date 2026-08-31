{ pkgs ? import <nixpkgs> { } }:
let
  eval = enabled: pkgs.lib.evalModules {
    specialArgs = { inherit pkgs; };
    modules = [
      ({ lib, ... }: {
        options = {
          home.packages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [ ];
          };
          programs.tmux.enable = lib.mkOption {
            type = lib.types.bool;
            default = enabled;
          };
          programs.tmux.keyMode = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
          programs.tmux.plugins = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [ ];
          };
          programs.tmux.extraConfig = lib.mkOption {
            type = lib.types.lines;
            default = "";
          };
        };
      })
      ./../home-modules/tmux
    ];
  };

  enabled = (eval true).config;
  disabled = (eval false).config;
  extraConfig = enabled.programs.tmux.extraConfig;
in
assert enabled.programs.tmux.keyMode == "emacs";
assert enabled.programs.tmux.plugins == [ pkgs.tmuxPlugins.yank ];
assert builtins.elem pkgs.wl-clipboard enabled.home.packages;
assert builtins.match ".*status-style bg=blue.*" extraConfig != null;
assert builtins.match ".*bind -n C-Space copy-mode.*" extraConfig != null;
assert builtins.match ".*bind -T copy-mode C-c send-keys -X copy-pipe-and-cancel wl-copy.*" extraConfig != null;
assert disabled.programs.tmux.keyMode == "";
assert disabled.programs.tmux.plugins == [ ];
assert disabled.home.packages == [ ];
assert disabled.programs.tmux.extraConfig == "";
true
