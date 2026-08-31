{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.programs.tmux.enable {
    home.packages = [ pkgs.wl-clipboard ];

    programs.tmux = {
      keyMode = "emacs";

      plugins = [
        pkgs.tmuxPlugins.yank
      ];

      extraConfig = ''
        # Set mode line background to blue
        set -g status-style bg=blue

        unbind C-Space
        unbind -T copy-mode C-Space
        unbind -T copy-mode C-c

        # Enter copy mode
        bind -n C-Space copy-mode

        # Navigation
        bind -T copy-mode C-Left send-keys -X previous-word
        bind -T copy-mode C-Right send-keys -X next-word

        # Shift select for up/down/left/right
        bind -T copy-mode S-Up if-shell -F "#{selection_present}" "send-keys -X cursor-up" "send-keys -X begin-selection; send-keys -X cursor-up"
        bind -T copy-mode S-Down if-shell -F "#{selection_present}" "send-keys -X cursor-down" "send-keys -X begin-selection; send-keys -X cursor-down"
        bind -T copy-mode S-Left if-shell -F "#{selection_present}" "send-keys -X cursor-left" "send-keys -X begin-selection; send-keys -X cursor-left"
        bind -T copy-mode S-Right if-shell -F "#{selection_present}" "send-keys -X cursor-right" "send-keys -X begin-selection; send-keys -X cursor-right"

        # Shift select next/last word
        bind -T copy-mode C-S-Left if-shell -F "#{selection_present}" "send-keys -X previous-word" "send-keys -X begin-selection; send-keys -X previous-word"
        bind -T copy-mode C-S-Right if-shell -F "#{selection_present}" "send-keys -X next-word" "send-keys -X begin-selection; send-keys -X next-word"
        bind -T copy-mode S-C-Left if-shell -F "#{selection_present}" "send-keys -X previous-word" "send-keys -X begin-selection; send-keys -X previous-word"
        bind -T copy-mode S-C-Right if-shell -F "#{selection_present}" "send-keys -X next-word" "send-keys -X begin-selection; send-keys -X next-word"

        # Shift select start/end of line
        bind -T copy-mode S-Home if-shell -F "#{selection_present}" "send-keys -X start-of-line" "send-keys -X begin-selection; send-keys -X start-of-line"
        bind -T copy-mode S-End if-shell -F "#{selection_present}" "send-keys -X end-of-line" "send-keys -X begin-selection; send-keys -X end-of-line"

        # Ctrl-C to copy
        bind -T copy-mode C-c send-keys -X copy-pipe-and-cancel wl-copy
      '';
    };
  };
}
