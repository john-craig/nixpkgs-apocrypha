{ config, lib, pkgs, ... }:
let
  cfg = config.evak.shell.cli;
  packageFor = name: if pkgs ? ${name} then pkgs.${name} else null;
  tool = name: description: {
    enable = lib.mkEnableOption description;
    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = packageFor name;
      description = "${description} package. Set this explicitly when it is absent from the pinned nixpkgs.";
    };
  };
  enabledPackages = lib.filter (p: p != null) (map (name: if cfg.${name}.enable then cfg.${name}.package else null) [
    "alucard" "chatgptCli" "claudeCode" "dismas" "instagram" "paru" "tea" "toot" "twitch"
  ]);
  required = name: cfg.${name}.enable && cfg.${name}.package == null;
  secretActivation = name: path: target: lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -r ${lib.escapeShellArg path} ]; then
      echo "evak.shell.cli.${name}: secret path ${path} is not readable" >&2
      exit 1
    fi
    install -m 0700 -d "$HOME/$(dirname ${lib.escapeShellArg target})"
    install -m 0600 ${lib.escapeShellArg path} "$HOME/${target}"
  '';
in
{
  options.evak.shell.cli = {
    alucard = tool "alucard" "Alucard deployment CLI" // {
      repositoryPath = lib.mkOption { type = lib.types.path; default = "${config.home.homeDirectory}/src/alucard"; };
      hostConfig = lib.mkOption { type = lib.types.attrs; default = { }; description = "Alucard host configuration."; };
    };
    chatgptCli = tool "chatgpt-cli" "ChatGPT CLI" // {
      credentialsPath = lib.mkOption { type = lib.types.nullOr lib.types.path; default = null; description = "External ChatGPT credentials file."; };
      credentialsTarget = lib.mkOption { type = lib.types.str; default = ".config/chatgpt-cli/credentials"; };
    };
    claudeCode = tool "claude-code" "Claude Code CLI";
    dismas = tool "dismas" "Dismas CLI";
    instagram = (tool "instagram-cli" "Instagram CLI") // {
      package = lib.mkOption { type = lib.types.nullOr lib.types.package; default = packageFor "instagram-cli"; description = "Instagram CLI package override."; };
    };
    paru = tool "paru" "Paru AUR helper";
    tea = tool "tea" "Tea Gitea CLI";
    toot = tool "toot" "Toot Mastodon CLI" // {
      credentialsPath = lib.mkOption { type = lib.types.nullOr lib.types.path; default = null; description = "External toot credentials file."; };
    };
    twitch = tool "twitch-cli" "Twitch CLI" // {
      credentialsPath = lib.mkOption { type = lib.types.nullOr lib.types.path; default = null; description = "External Twitch credentials environment file."; };
    };
  };

  config = {
    assertions = map (name: {
      assertion = !required name;
      message = "evak.shell.cli.${name} is enabled, but its package is unavailable; set evak.shell.cli.${name}.package.";
    }) [ "alucard" "chatgptCli" "claudeCode" "dismas" "instagram" "paru" "tea" "toot" "twitch" ];

    home.packages = lib.mkIf (lib.any (name: cfg.${name}.enable) [ "alucard" "chatgptCli" "claudeCode" "dismas" "instagram" "paru" "tea" "toot" "twitch" ]) enabledPackages;

    home.file.".config/alucard/hosts.nix" = lib.mkIf cfg.alucard.enable {
      text = builtins.toJSON cfg.alucard.hostConfig;
    };

    programs.zsh.initContent = lib.mkIf cfg.alucard.enable ''
      if [[ -r ${lib.escapeShellArg "${cfg.alucard.repositoryPath}/completions/alucard.zsh"} ]]; then
        source ${lib.escapeShellArg "${cfg.alucard.repositoryPath}/completions/alucard.zsh"}
      fi
    '';

    home.activation = {
      chatgptCliCredentials = lib.mkIf (cfg.chatgptCli.enable && cfg.chatgptCli.credentialsPath != null) (secretActivation "chatgptCli" cfg.chatgptCli.credentialsPath cfg.chatgptCli.credentialsTarget);
      tootCredentials = lib.mkIf (cfg.toot.enable && cfg.toot.credentialsPath != null) (secretActivation "toot" cfg.toot.credentialsPath ".config/toot/credentials");
      twitchCredentials = lib.mkIf (cfg.twitch.enable && cfg.twitch.credentialsPath != null) (secretActivation "twitch" cfg.twitch.credentialsPath ".config/twitch-cli/credentials.env");
    };
  };
}
