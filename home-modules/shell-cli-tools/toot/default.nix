{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.evak.shell.cli.toot;
  helpers = import ../helpers.nix { inherit config lib pkgs; };
in
{
  options.evak.shell.cli.toot = helpers.tool "toot" "Toot Mastodon CLI" // {
    credentialsPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "External toot credentials file.";
    };
  };
  config = {
    assertions = [
      {
        assertion = !cfg.enable || cfg.package != null;
        message = "evak.shell.cli.toot requires a package override.";
      }
    ];
    home.packages = lib.mkIf cfg.enable [ cfg.package ];
    home.activation.tootCredentials = lib.mkIf (cfg.enable && cfg.credentialsPath != null) (
      helpers.secretActivation "toot" cfg.credentialsPath ".config/toot/credentials"
    );
  };
}
