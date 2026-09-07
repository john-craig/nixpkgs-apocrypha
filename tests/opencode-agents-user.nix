{ pkgs }:
let
  module = ../nixos-modules/opencode-agents-user.nix;
  assertionsType = pkgs.lib.types.listOf (
    pkgs.lib.types.submodule {
      options = {
        assertion = pkgs.lib.mkOption { type = pkgs.lib.types.bool; };
        message = pkgs.lib.mkOption { type = pkgs.lib.types.str; };
      };
    }
  );
  eval = extra:
    pkgs.lib.evalModules {
      modules = [
        ({ lib, ... }: {
          options.assertions = lib.mkOption {
            type = assertionsType;
            default = [ ];
          };
          options.users.users = lib.mkOption {
            type = lib.types.attrsOf lib.types.attrs;
            default = { };
          };
          options.home-manager.users = lib.mkOption {
            type = lib.types.attrsOf (lib.types.submodule {
              options = {
                imports = lib.mkOption {
                  type = lib.types.listOf (lib.types.either lib.types.path lib.types.attrs);
                  default = [ ];
                };
                home = lib.mkOption {
                  type = lib.types.attrs;
                  default = { };
                };
                evak.opencode.enable = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                };
                evak.opencode.settings = lib.mkOption {
                  type = lib.types.attrs;
                  default = { };
                };
                evak.opencode-agents.enable = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                };
                evak.opencode-agents.opencodePackage = lib.mkOption {
                  type = lib.types.nullOr lib.types.package;
                  default = null;
                };
                evak.opencode-agents.agents = lib.mkOption {
                  type = lib.types.attrs;
                  default = { };
                };
                evak.project-manager.automated-development-workflows.implementor-scheduler = lib.mkOption {
                  type = lib.types.attrs;
                  default = { };
                };
              };
            });
            default = { };
          };
        })
        module
        extra
      ];
    };
  enabled = eval {
    config.evak.opencodeAgentsUser = {
      enable = true;
      username = "agent-user";
      user = {
        description = "OpenCode agent user";
        uid = 4242;
        extraGroups = [ "wheel" "dialout" ];
      };
      homeManager = {
        home.stateVersion = "24.11";
        evak.opencode.settings.model = "openai/test";
        evak.opencode-agents.enable = false;
        evak.opencode-agents.opencodePackage = pkgs.opencode;
        evak.opencode-agents.agents.custom = {
          description = "A test agent.";
          prompt = "Do the test task.";
        };
        evak.project-manager.automated-development-workflows.implementor-scheduler = {
          enable = true;
          interval = "12h";
          upstreams = [ { url = "https://github.com/owner/repo.git"; } ];
        };
      };
    };
    config.users.users.other-user.description = "Untouched";
    config.home-manager.users.other-user.home.stateVersion = "24.11";
  };
  disabled = eval {
    config.evak.opencodeAgentsUser.username = "disabled-user";
  };
  renamed = eval {
    config.evak.opencodeAgentsUser = {
      enable = true;
      username = "renamed-user";
    };
  };
  invalidUsername = builtins.tryEval (
    builtins.deepSeq ((eval {
      config.evak.opencodeAgentsUser = {
        enable = true;
        username = "InvalidUsername";
      };
    }).config.evak.opencodeAgentsUser.username) true
  );
  unsupportedUserOption = builtins.tryEval (
    builtins.deepSeq ((eval {
      config.evak.opencodeAgentsUser = {
        enable = true;
        username = "agent-user";
        user.unsupported = true;
      };
    }).config.users.users) true
  );
  missingHomeManager = pkgs.lib.evalModules {
    modules = [
      ({ lib, ... }: {
        options.assertions = lib.mkOption {
          type = assertionsType;
          default = [ ];
        };
        options.users.users = lib.mkOption {
          type = lib.types.attrsOf lib.types.attrs;
          default = { };
        };
      })
      module
      { config.evak.opencodeAgentsUser = { enable = true; username = "agent-user"; }; }
    ];
  };
  homeEval = pkgs.lib.evalModules {
    specialArgs = { inherit pkgs; };
    modules = [
      ({ lib, ... }: {
        options.assertions = lib.mkOption {
          type = assertionsType;
          default = [ ];
        };
        options.home.file = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                source = lib.mkOption { type = lib.types.nullOr lib.types.path; default = null; };
                text = lib.mkOption { type = lib.types.nullOr lib.types.lines; default = null; };
              };
            }
          );
          default = { };
        };
        options.home.packages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
        };
      })
      ../home-modules/opencode
      ../home-modules/opencode-agents
      {
        config.evak.opencode.enable = true;
        config.evak.opencode-agents = {
          enable = true;
          opencodePackage = pkgs.opencode;
          agents.custom = {
            description = "A test agent.";
            prompt = "Do the test task.";
          };
        };
      }
    ];
  };
  schedulerPackage = pkgs.writeShellScriptBin "openspec-implementor" "exit 0";
  schedulerDisabledHomeEval = pkgs.lib.evalModules {
    specialArgs = { inherit pkgs; };
    modules = [
      ({ lib, ... }: {
        options.assertions = lib.mkOption {
          type = assertionsType;
          default = [ ];
        };
        options.home.packages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
        };
        options.systemd.user.services = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = { };
        };
        options.systemd.user.timers = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = { };
        };
      })
      ../home-modules/project-manager/automated-development-workflows/implementor-scheduler
    ];
  };
  schedulerHomeEval = pkgs.lib.evalModules {
    specialArgs = { inherit pkgs; };
    modules = [
      ({ lib, ... }: {
        options.home.packages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
        };
        options.systemd.user.services = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = { };
        };
        options.systemd.user.timers = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = { };
        };
        options.assertions = lib.mkOption {
          type = assertionsType;
          default = [ ];
        };
      })
      ../home-modules/project-manager/automated-development-workflows/implementor-scheduler
      {
        evak.project-manager.automated-development-workflows.implementor-scheduler = {
          enable = true;
          implementorPackage = schedulerPackage;
          upstreams = [ { url = "https://github.com/owner/repo.git"; } ];
        };
      }
    ];
  };
  enabledAssertions = builtins.all (item: item.assertion) enabled.config.assertions;
  missingHomeManagerAssertion = builtins.head (
    builtins.filter (item: !item.assertion) missingHomeManager.config.assertions
  );
  user = enabled.config.users.users.agent-user;
  homeUser = enabled.config.home-manager.users.agent-user;
  homeFiles = homeEval.config.home.file;
in
assert enabledAssertions;
assert user.description == "OpenCode agent user";
assert user.uid == 4242;
assert user.extraGroups == [ "wheel" "dialout" ];
assert enabled.config.users.users.other-user.description == "Untouched";
assert enabled.config.home-manager.users.other-user.home.stateVersion == "24.11";
assert disabled.config.users.users == { };
assert disabled.config.home-manager.users == { };
assert builtins.hasAttr "renamed-user" renamed.config.users.users;
assert !builtins.hasAttr "agent-user" renamed.config.users.users;
assert !invalidUsername.success;
assert !unsupportedUserOption.success;
assert builtins.elem ../home-modules/opencode homeUser.imports;
assert builtins.elem ../home-modules/opencode-agents homeUser.imports;
assert builtins.elem ../home-modules/project-manager/automated-development-workflows/implementor-scheduler homeUser.imports;
assert homeUser.evak.opencode.enable == true;
assert homeUser.evak.opencode-agents.enable == true;
assert homeUser.evak.project-manager.automated-development-workflows.implementor-scheduler.enable == true;
assert homeUser.evak.project-manager.automated-development-workflows.implementor-scheduler.interval == "12h";
assert homeUser.evak.opencode-agents.opencodePackage == pkgs.opencode;
assert homeUser.evak.opencode.settings.model == "openai/test";
assert homeUser.evak.opencode-agents.agents.custom.description == "A test agent.";
assert !missingHomeManagerAssertion.assertion;
assert builtins.match ".*home-manager.users.*" missingHomeManagerAssertion.message != null;
assert builtins.hasAttr ".config/opencode/opencode.json" homeFiles;
assert builtins.hasAttr ".config/opencode/opencode-agents.json" homeFiles;
assert builtins.hasAttr ".config/opencode/environments/custom.json" homeFiles;
assert builtins.length homeEval.config.home.packages == 1;
assert schedulerDisabledHomeEval.config.home.packages == [ ];
assert schedulerDisabledHomeEval.config.systemd.user.services == { };
assert schedulerDisabledHomeEval.config.systemd.user.timers == { };
assert builtins.hasAttr "evak-openspec-implementor-scheduler" schedulerHomeEval.config.systemd.user.services;
assert builtins.hasAttr "evak-openspec-implementor-scheduler" schedulerHomeEval.config.systemd.user.timers;
pkgs.runCommand "opencode-agents-user-test" { } "touch $out"
