{ config, lib, pkgs, ... }:
let
  cfg = config.evak.opencode;
  json = pkgs.formats.json { };

  opencodeConfig = json.generate "opencode.json" ({
    "$schema" = "https://opencode.ai/config.json";
    plugin = cfg.plugins;
  } // cfg.settings);

  tuiConfig = json.generate "tui.json" ({
    "$schema" = "https://opencode.ai/tui.json";
    theme = cfg.theme;
  } // cfg.tui.settings);

  themeConfig = json.generate "synthwave-84.json" {
    "$schema" = "https://opencode.ai/theme.json";
    defs = {
      background = "#262335";
      panel = "#241b2f";
      foreground = "#f9f4ff";
      muted = "#9580a8";
      pink = "#ff7edb";
      cyan = "#36f9f6";
      yellow = "#fede5d";
      orange = "#f97e72";
      purple = "#b084eb";
      green = "#72f1b8";
      blue = "#8481ff";
    };
    theme = {
      primary = "pink";
      secondary = "purple";
      accent = "cyan";
      error = "orange";
      warning = "yellow";
      success = "green";
      info = "blue";
      text = "foreground";
      textMuted = "muted";
      background = "background";
      backgroundPanel = "panel";
      backgroundElement = "#34294f";
      border = "#59456f";
      borderActive = "pink";
      borderSubtle = "#3b2d4d";
      diffAdded = "green";
      diffRemoved = "orange";
      diffContext = "muted";
      diffHunkHeader = "purple";
      diffAddedBg = "#183d3a";
      diffRemovedBg = "#492a3d";
      diffContextBg = "panel";
      diffLineNumber = "muted";
      diffAddedLineNumberBg = "#183d3a";
      diffRemovedLineNumberBg = "#492a3d";
      markdownText = "foreground";
      markdownHeading = "pink";
      markdownLink = "cyan";
      markdownLinkText = "blue";
      markdownCode = "yellow";
      markdownBlockQuote = "muted";
      markdownEmph = "orange";
      markdownStrong = "pink";
      markdownHorizontalRule = "muted";
      markdownListItem = "cyan";
      markdownListEnumeration = "purple";
      markdownImage = "blue";
      markdownImageText = "cyan";
      markdownCodeBlock = "foreground";
      syntaxComment = "muted";
      syntaxKeyword = "pink";
      syntaxFunction = "cyan";
      syntaxVariable = "purple";
      syntaxString = "green";
      syntaxNumber = "yellow";
      syntaxType = "blue";
      syntaxOperator = "orange";
      syntaxPunctuation = "foreground";
    };
  };

  notifierCommand = pkgs.writeShellScript "opencode-notifier-command" ''
    set -u

    event="''${1:-complete}"
    message="''${2:-OpenCode finished processing your request.}"
    title="OpenCode $event"
    token_path=${lib.escapeShellArg cfg.notifications.tokenPath}
    gotify_url=${lib.escapeShellArg cfg.notifications.gotifyUrl}
    gotify_priority=${toString cfg.notifications.gotifyPriority}
    fallback=1

    if [[ -r "$token_path" ]]; then
      token="$(${pkgs.coreutils}/bin/tr -d '\n' < "$token_path")"
      if [[ -n "$token" ]] && ${pkgs.curl}/bin/curl -fsS -o /dev/null \
        -H "X-Gotify-Key: $token" \
        -H 'Content-Type: application/json' \
        --data "$(${pkgs.jq}/bin/jq -cn --arg title "$title" --arg message "$message" --argjson priority "$gotify_priority" \
          '{title: $title, message: $message, priority: $priority, extras: {"client::display": {contentType: "text/markdown"}}}')" \
        "$gotify_url/message"; then
        fallback=0
      fi
    fi

    if [[ "$fallback" -eq 1 ]] && command -v hyprctl >/dev/null 2>&1; then
      hyprctl notify 1 5000 0 "$title" >/dev/null 2>&1 || true
    fi
  '';

  notifierConfig = json.generate "opencode-notifier.json" {
    sound = true;
    notification = true;
    suppressWhenFocused = false;
    minDuration = 10;
    sounds.complete = toString ./ding.mp3;
    command = {
      enabled = true;
      path = notifierCommand;
      args = [ "{event}" "{message}" ];
      minDuration = 10;
    };
  };
in
{
  options.evak.opencode = {
    enable = lib.mkEnableOption "evak's OpenCode TUI customizations";

    theme = lib.mkOption {
      type = lib.types.str;
      default = "synthwave-84";
      description = "Global OpenCode TUI theme name.";
    };

    tui.settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Additional settings written to OpenCode's tui.json.";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Additional settings written to OpenCode's config.json.";
    };

    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "@mohak34/opencode-notifier@0.1.36"
        "opencode-codex-quota@1.0.1"
        "opencode-quotes-plugin/tui"
      ];
      description = "OpenCode plugins loaded by the managed configuration.";
    };

    notifications = {
      gotifyUrl = lib.mkOption {
        type = lib.types.str;
        default = "https://gotify.chiliahedron.wtf";
        description = "Gotify endpoint used for OpenCode completion notifications.";
      };

      tokenPath = lib.mkOption {
        type = lib.types.str;
        default = "/run/user/1000/secrets/gotify/api_token";
        description = "Runtime path to the Gotify API token.";
      };

      gotifyPriority = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 5;
        description = "Gotify priority for OpenCode completion notifications.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.file.".config/opencode/opencode.json".source = opencodeConfig;
    home.file.".config/opencode/tui.json".source = tuiConfig;
    home.file.".config/opencode/opencode-notifier.json".source = notifierConfig;
    home.file.".config/opencode/themes/${cfg.theme}.json".source = themeConfig;
    home.file.".config/opencode/ding.mp3".source = ./ding.mp3;
  };
}
