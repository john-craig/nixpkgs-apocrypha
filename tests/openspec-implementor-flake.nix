{pkgs}: let
  fake = name: pkgs.writeShellScriptBin name "exit 0";
  package = pkgs.callPackage ./../pkgs/openspec-implementor {
    opencodeAgentPackage = fake "opencode-agent";
    openspecPackage = fake "openspec";
    opencodePackage = fake "opencode";
  };
in
  assert package.meta.mainProgram == "openspec-implementor";
  pkgs.runCommand "openspec-implementor-flake-test" {
    nativeBuildInputs = [package];
  } ''
    set -euo pipefail
    openspec-implementor --help 2>&1 | grep -q 'Usage: openspec-implementor'
    if openspec-implementor --upstream invalid-url 2>error; then
      exit 1
    fi
    grep -q 'invalid upstream URL' error
    touch "$out"
  ''
