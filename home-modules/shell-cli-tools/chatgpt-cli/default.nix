{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.evak.shell.cli.chatgptCli;
  helpers = import ../helpers.nix { inherit config lib pkgs; };
in
{
  options.evak.shell.cli.chatgptCli = helpers.tool "chatgpt-cli" "ChatGPT CLI" // {
    credentialsPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "External ChatGPT credentials file.";
    };
    credentialsTarget = lib.mkOption {
      type = lib.types.str;
      default = ".config/chatgpt-cli/credentials";
    };
  };
  config = {
    assertions = [
      {
        assertion = !cfg.enable || cfg.package != null;
        message = "evak.shell.cli.chatgptCli is enabled, but its package is unavailable; set evak.shell.cli.chatgptCli.package.";
      }
    ];
    home.packages = lib.mkIf cfg.enable [ cfg.package ];
    home.activation.chatgptCliCredentials = lib.mkIf (cfg.enable && cfg.credentialsPath != null) (
      helpers.secretActivation "chatgptCli" cfg.credentialsPath cfg.credentialsTarget
    );
  };
}
