{ config, lib, pkgs, ... }:
let
  vscodiumEnabled = config.programs.vscode.enable;

  synthwaveExtension = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "synthwave-vscode";
      publisher = "robbowen";
      version = "0.1.18";
      hash = "sha256-me5aPVAyOAhP+Iy1ACkoBpCfS1LlsZmk8CAjNuZyojg=";
    };
  };

  neonCssPatch = pkgs.writeText "synthwave84-neon.css" ''
    /* BEGIN Synthwave84 Neon Patch */
    ${builtins.readFile "${synthwaveExtension}/share/vscode/extensions/robbowen.synthwave-vscode/synthwave84.css"}
    /* END Synthwave84 Neon Patch */
  '';

  vscodium = pkgs.vscodium.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      echo "Patching workbench.desktop.main.css for Synthwave '84 neon..."
      cssFile=$out/lib/vscode/resources/app/out/vs/workbench/workbench.desktop.main.css
      cp $cssFile $cssFile.bak
      cat ${neonCssPatch} >> $cssFile
    '';
  });
in
{
  config = lib.mkIf vscodiumEnabled {
    programs.vscode = {
      package = vscodium;

      profiles.default = {
        keybindings = [
          {
            key = "ctrl+shift+x";
            command = "-workbench.view.extensions";
            when = "viewContainer.workbench.view.extensions.enabled";
          }
          {
            key = "ctrl+shift+left";
            command = "-workbench.action.terminal.resizePaneLeft";
            when = "terminalFocus && terminalHasBeenCreated || terminalFocus && terminalProcessSupported";
          }
          {
            key = "ctrl+shift+right";
            command = "-workbench.action.terminal.resizePaneRight";
            when = "terminalFocus && terminalHasBeenCreated || terminalFocus && terminalProcessSupported";
          }
        ];

        userSettings = {
          "workbench.colorTheme" = "SynthWave '84";
          "security.workspace.trust.untrustedFiles" = "open";
          "terminal.integrated.allowChords" = false;
          "terminal.integrated.defaultProfile.linux" = lib.mkForce "tmux";
          "terminal.integrated.profiles.linux" = {
            tmux = {
              path = "zsh";
              args = [ "-c" "tmux" ];
              icon = "terminal-tmux";
            };
          };
          "editor.fontFamily" = "'JetBrains Mono', 'monospace', monospace";
          "editor.fontLigatures" = true;
        };

        extensions = [
          pkgs.vscode-extensions.wholroyd.jinja
          pkgs.vscode-extensions.ms-python.python
          pkgs.vscode-extensions.github.copilot
          pkgs.vscode-extensions.jnoortheen.nix-ide
          synthwaveExtension
        ];
      };
    };
  };
}
