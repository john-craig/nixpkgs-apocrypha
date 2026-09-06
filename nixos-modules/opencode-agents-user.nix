{ config, lib, options, ... }:
let
  cfg = config.evak.opencodeAgentsUser;
  homeManagerAvailable = lib.hasAttrByPath [ "home-manager" "users" ] options;

  userType = lib.types.submodule ({ config, ... }: {
    options = {
      isNormalUser = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether the OpenCode user is a normal (non-system) user.";
      };

      isSystemUser = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether the OpenCode user is a system user.";
      };

      description = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "GECOS description for the OpenCode user.";
      };

      home = lib.mkOption {
        type = lib.types.str;
        default = "/home/${cfg.username}";
        description = "Home directory for the OpenCode user.";
      };

      createHome = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to create the OpenCode user's home directory.";
      };

      homeMode = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Permissions for the OpenCode user's home directory.";
      };

      uid = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.unsigned;
        default = null;
        description = "Numeric UID for the OpenCode user.";
      };

      group = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Primary group for the OpenCode user.";
      };

      extraGroups = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Supplementary groups for the OpenCode user.";
      };

      shell = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = null;
        description = "Login shell for the OpenCode user.";
      };

      useDefaultShell = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to use the system default shell.";
      };

      initialPassword = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Initial password for the OpenCode user.";
      };

      hashedPassword = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Hashed password for the OpenCode user.";
      };

      hashedPasswordFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "File containing the OpenCode user's hashed password.";
      };

      passwordFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "File containing the OpenCode user's password.";
      };

      packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        description = "Packages installed for the OpenCode user.";
      };
    };
  });
in
{
  options.evak.opencodeAgentsUser = {
    enable = lib.mkEnableOption "a NixOS user with OpenCode agent environments";

    username = lib.mkOption {
      type = lib.types.strMatching "[a-z_][a-z0-9_-]*\\$?";
      default = "";
      description = "Username that receives the OpenCode Home Manager profile.";
    };

    user = lib.mkOption {
      type = userType;
      default = { };
      description = "NixOS user attributes for the OpenCode user.";
    };

    homeManager = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Additional Home Manager configuration for the OpenCode user.";
    };
  };

  config = lib.mkIf cfg.enable (
    {
      assertions = [
        {
          assertion = cfg.username != "";
          message = "evak.opencodeAgentsUser.username must be set when the module is enabled.";
        }
        {
          assertion = homeManagerAvailable;
          message = "evak.opencodeAgentsUser requires the Home Manager NixOS module, which provides home-manager.users.";
        }
      ];

      users.users.${cfg.username} = cfg.user;
    }
    // lib.optionalAttrs homeManagerAvailable {
      home-manager.users.${cfg.username} = lib.mkMerge [
        cfg.homeManager
        {
          imports = [
            ../home-modules/opencode
            ../home-modules/opencode-agents
          ];
          evak.opencode.enable = lib.mkForce true;
          evak.opencode-agents.enable = lib.mkForce true;
        }
      ];
    }
  );
}
