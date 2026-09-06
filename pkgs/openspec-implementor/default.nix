{
  lib,
  pkgs,
  opencodeAgentPackage,
  openspecPackage ? null,
  opencodePackage ? null,
}:
let
  moduleEval = pkgs.lib.evalModules {
    specialArgs = {inherit pkgs;};
    modules = [
      ({lib, ...}: {
        options.assertions = lib.mkOption {
          type = lib.types.listOf (lib.types.submodule {
            options = {
              assertion = lib.mkOption {type = lib.types.bool;};
              message = lib.mkOption {type = lib.types.str;};
            };
          });
          default = [];
        };
        options.home.packages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [];
        };
      })
      ../../home-modules/project-manager/automated-development-workflows/implementor
      ({...}: {
        config.evak.project-manager.automated-development-workflows.implementor = {
          enable = true;
          gitPackage = pkgs.git;
          awkPackage = pkgs.gawk;
          findutilsPackage = pkgs.findutils;
          jqPackage = pkgs.jq;
          inherit openspecPackage opencodeAgentPackage;
          ghPackage = pkgs.gh;
          teaPackage = pkgs.tea;
        };
      })
    ];
  };
  failedAssertions = lib.filter (item: !item.assertion) moduleEval.config.assertions;
  runner = builtins.head moduleEval.config.home.packages;
  opencode =
    if opencodePackage != null
    then opencodePackage
    else if builtins.hasAttr "opencode" pkgs
    then pkgs.opencode
    else null;
in
  if openspecPackage == null
  then throw "openspec-implementor requires an OpenSpec package; provide openspecPackage"
  else if opencode == null
  then throw "openspec-implementor requires an OpenCode package; apply the opencode-nix overlay or provide opencodePackage"
  else if failedAssertions != []
  then throw (lib.concatMapStringsSep "\n" (item: item.message) failedAssertions)
  else pkgs.writeShellApplication {
    name = "openspec-implementor";
    runtimeInputs = [runner opencode];
    text = ''
      exec ${runner}/bin/openspec-implementor "$@"
    '';
    meta = {
      description = "Run an OpenSpec implementation workflow against an upstream repository";
      homepage = "https://github.com/john-craig/nixpkgs-apocrypha";
      mainProgram = "openspec-implementor";
      platforms = lib.platforms.unix;
    };
  }
