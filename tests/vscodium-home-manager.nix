{ pkgs ? import <nixpkgs> { } }:
let
  eval = enable: pkgs.lib.evalModules {
    specialArgs = { inherit pkgs; };
    modules = [
      ({ lib, ... }: {
        options = {
          programs.vscode.enable = lib.mkOption {
            type = lib.types.bool;
            default = enable;
          };
          programs.vscode.package = lib.mkOption {
            type = lib.types.nullOr lib.types.package;
            default = null;
          };
          programs.vscode.mutableExtensionsDir = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          programs.vscode.profiles = lib.mkOption {
            type = lib.types.attrsOf (lib.types.submodule ({ lib, ... }: {
              options = {
                keybindings = lib.mkOption { type = lib.types.anything; default = [ ]; };
                userSettings = lib.mkOption { type = lib.types.anything; default = { }; };
                extensions = lib.mkOption { type = lib.types.listOf lib.types.package; default = [ ]; };
              };
            }));
            default = { };
          };
        };
      })
      ./../home-modules/vscodium
    ];
  };

  enabled = (eval true).config.programs.vscode;
  disabled = (eval false).config.programs.vscode;
  profile = enabled.profiles.default;
in
assert enabled.package != null;
assert enabled.mutableExtensionsDir == false;
assert profile.userSettings."workbench.colorTheme" == "SynthWave '84";
assert profile.userSettings."terminal.integrated.defaultProfile.linux" == "tmux";
assert profile.userSettings."terminal.integrated.profiles.linux".tmux.args == [ "-c" "tmux" ];
assert profile.userSettings."editor.fontLigatures";
assert builtins.length profile.extensions == 5;
assert builtins.length profile.keybindings == 3;
assert (builtins.head profile.keybindings).key == "ctrl+shift+x";
assert disabled.package == null;
assert disabled.profiles == { };
true
