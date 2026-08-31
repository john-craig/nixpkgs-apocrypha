{ config, lib, pkgs, ... }:
let
  cfg = config.evak.zsh;
  zshEnabled = config.programs.zsh.enable;
  homeDirectory = config.home.homeDirectory;

  notifyPlugin = pkgs.writeText "evak-zsh-notify.plugin.zsh" ''
    #!/bin/zsh

    LONG_RUNNING=${toString cfg.notifications.thresholdSeconds}
    GOTIFY_URL=${lib.escapeShellArg (if cfg.notifications.gotifyUrl == null then "" else cfg.notifications.gotifyUrl)}
    API_TOKEN_PATH=${lib.escapeShellArg (if cfg.notifications.tokenPath == null then "" else cfg.notifications.tokenPath)}
    FALLBACK_COMMAND=${lib.escapeShellArg cfg.notifications.fallbackCommand}

    send_notification() {
        local title="$1"
        local message="$2"
        local priority="''${3:-5}"
        local fallback=1

        if [[ -n "$GOTIFY_URL" && -f "$API_TOKEN_PATH" ]]; then
            if {
                {
                    printf 'X-Gotify-Key: '
                    tr -d '\n' < "$API_TOKEN_PATH"
                } | ${pkgs.curl}/bin/curl -s -S \
                    -H @- \
                    -H 'Content-Type: application/json' \
                    --data "{\"message\":\"$message\",\"title\":\"$title\",\"priority\":$priority}" \
                    "$GOTIFY_URL" > /dev/null
            }; then
                fallback=0
            fi
        fi

        if (( fallback == 1 )) && [[ -n "$FALLBACK_COMMAND" ]]; then
            eval "$FALLBACK_COMMAND \"Command $title completed\"" > /dev/null 2>&1 || true
        fi
    }

    start_notify_timer() {
        CMD_START_TIME=$SECONDS
        CMD_STRING="$1"
    }

    end_notify_timer() {
        local command_status=$?
        local command_run_time=$((SECONDS - CMD_START_TIME))

        if [[ -n "$CMD_START_TIME" && $command_run_time -gt $LONG_RUNNING ]]; then
            send_notification "$CMD_STRING" "Command Completed!"
        fi

        unset CMD_START_TIME CMD_STRING
        return $command_status
    }

    preexec_functions+=(start_notify_timer)
    precmd_functions+=(end_notify_timer)
  '';
in
{
  options.evak.zsh = {
    notifications = {
      enable = lib.mkEnableOption "long-running zsh command notifications";

      thresholdSeconds = lib.mkOption {
        type = lib.types.ints.nonnegative;
        default = 5;
        description = "Command duration in seconds before a notification is sent.";
      };

      gotifyUrl = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Gotify message endpoint; null disables the Gotify attempt.";
      };

      tokenPath = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Path to the Gotify API token file.";
      };

      fallbackCommand = lib.mkOption {
        type = lib.types.str;
        default = "hyprctl notify 1 5000 0";
        description = "Command used when Gotify delivery is unavailable.";
      };
    };

    historyMetadata = lib.mkEnableOption "extended zsh history metadata";

  };

  config = lib.mkIf zshEnabled (lib.mkMerge [
    {
      home.file.".zprofile".source = ./zprofile.zsh;

      programs.zsh = {
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        historySubstringSearch.enable = true;

        completionInit = lib.mkDefault ''
          autoload -Uz compinit && compinit
        '';

        plugins = [
          {
            name = "alpine-zsh-config";
            src = pkgs.fetchFromGitHub {
              owner = "jirutka";
              repo = "alpine-zsh-config";
              rev = "v0.5.0";
              hash = "sha256-mbt2Oqdqylup759tUTN2erqDmSv1bH1BcpW2XApHudc=";
            };
            file = "zshrc.d/50-key-bindings.zsh";
          }
        ] ++ lib.optional cfg.notifications.enable {
          name = "notify";
          src = notifyPlugin;
        };
      };
    }
    (lib.mkIf cfg.historyMetadata {
      programs.zsh.history = {
        path = "${homeDirectory}/.zsh_history";
        size = 100000;
        save = 100000;
        ignoreDups = false;
        extended = true;
      };
    })
    (lib.mkIf cfg.notifications.enable {
      home.packages = [ pkgs.curl ];
    })
  ]);
}
