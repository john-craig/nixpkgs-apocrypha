{pkgs}: let
  fakeGit = pkgs.writeShellScriptBin "git" ''
    set -euo pipefail
    real_git=${pkgs.git}/bin/git
    case "''${1:-}" in
      clone)
        source="''${2/https:\/\/github.com\/owner\/repo.git/file:\/\/$REMOTE}"
        shift 2
        exec "$real_git" clone "$source" "$@"
        ;;
      ls-remote)
        args=()
        for argument in "$@"; do
          args+=("''${argument/https:\/\/github.com\/owner\/repo.git/file:\/\/$REMOTE}")
        done
        exec "$real_git" "''${args[@]}"
        ;;
      *)
        exec "$real_git" "$@"
        ;;
    esac
  '';
  fakeJq = pkgs.jq;
  fakeOpenSpec = pkgs.writeShellScriptBin "openspec" ''
    set -euo pipefail
    case "''${1:-}" in
      list)
        printf '%s\n' '{"changes":[{"name":"software-architect-add-feature"}]}'
        ;;
      status)
        printf '%s\n' '{"isPlanningComplete":true,"isComplete":true}'
        ;;
      *)
        exit 1
        ;;
    esac
  '';
  fakeOpenCodeAgent = pkgs.writeShellScriptBin "opencode-agent" ''
    set -euo pipefail
    directory=""
    agent=""
    while (($# > 0)); do
      case "$1" in
        --directory) directory="$2"; shift 2 ;;
        --agent) agent="$2"; shift 2 ;;
        --prompt) shift 2 ;;
        *) shift ;;
      esac
    done
    test "$agent" = software-architect
    test -n "$directory"
    mkdir -p "$directory/openspec/changes/archive/2026-09-05-software-architect-add-feature"
    mv "$directory/openspec/changes/software-architect-add-feature/.openspec.yaml" \
      "$directory/openspec/changes/archive/2026-09-05-software-architect-add-feature/"
    rmdir "$directory/openspec/changes/software-architect-add-feature"
    printf '%s\n' implemented > "$directory/implementation.txt"
  '';
  fakeGh = pkgs.writeShellScriptBin "gh" ''
    set -euo pipefail
    if [[ "$1 $2" == "pr list" ]]; then
      printf '%s\n' '[]'
    else
      printf '%s\n' 'https://github.com/owner/repo/pull/1'
    fi
  '';
  fakeTea = pkgs.writeShellScriptBin "tea" ''
    set -euo pipefail
    if [[ "$1 $2" == "pulls ls" ]]; then
      printf '%s\n' '[{"number":1}]'
    else
      printf '%s\n' 'https://gitea.example/owner/repo/pulls/1'
    fi
  '';
  eval = enabled: extra:
    pkgs.lib.evalModules {
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
          config.evak.project-manager.automated-development-workflows.implementor.enable = enabled;
        })
        ./../home-modules/project-manager/automated-development-workflows/implementor
        extra
      ];
    };
  disabled = eval false {};
  enabled = eval true {
    config.evak.project-manager.automated-development-workflows.implementor = {
      gitPackage = fakeGit;
      jqPackage = fakeJq;
      openspecPackage = fakeOpenSpec;
      opencodeAgentPackage = fakeOpenCodeAgent;
      ghPackage = fakeGh;
      teaPackage = fakeTea;
    };
  };
  runner = builtins.head enabled.config.home.packages;
in
  assert disabled.config.home.packages == [];
  assert builtins.length enabled.config.home.packages == 1;
  assert builtins.match ".*openspec-implementor.*" runner.name != null;
  pkgs.runCommand "openspec-implementor-test" {
    nativeBuildInputs = [runner];
  } ''
    set -euo pipefail
    openspec-implementor --help >/dev/null
    if openspec-implementor --upstream invalid-url 2>error; then
      exit 1
    fi
    grep -q 'invalid upstream URL' error

    remote="$PWD/remote.git"
    seed="$PWD/seed"
    ${pkgs.git}/bin/git init --bare "$remote" >/dev/null
    ${pkgs.git}/bin/git clone "$remote" "$seed" >/dev/null
    ${pkgs.git}/bin/git -C "$seed" config user.email test@example.invalid
    ${pkgs.git}/bin/git -C "$seed" config user.name test
    mkdir -p "$seed/openspec/changes/software-architect-add-feature"
    printf '%s\n' 'schema: spec-driven' > "$seed/openspec/changes/software-architect-add-feature/.openspec.yaml"
    ${pkgs.git}/bin/git -C "$seed" add .
    ${pkgs.git}/bin/git -C "$seed" commit -m initial >/dev/null
    ${pkgs.git}/bin/git -C "$seed" branch -M main
    ${pkgs.git}/bin/git -C "$seed" push origin main >/dev/null
    export REMOTE="$remote"
    export WORK_ROOT="$PWD/work-root"
    export GIT_AUTHOR_NAME=test
    export GIT_AUTHOR_EMAIL=test@example.invalid
    export GIT_COMMITTER_NAME=test
    export GIT_COMMITTER_EMAIL=test@example.invalid
    mkdir "$WORK_ROOT"
    openspec-implementor \
      --upstream https://github.com/owner/repo.git \
      --work-root "$WORK_ROOT" \
      --base main > result
    grep -q 'https://github.com/owner/repo/pull/1' result
    test -z "$(find "$WORK_ROOT" -mindepth 1 -maxdepth 1 -print)"
    test "$(${pkgs.git}/bin/git --git-dir="$remote" show feature/software-architect-add-feature:implementation.txt)" = implemented
    if openspec-implementor \
      --upstream https://github.com/owner/repo.git \
      --provider gitea \
      --change software-architect-add-feature \
      --work-root "$WORK_ROOT" \
      --base main 2>pending-error; then
      exit 1
    fi
    grep -q 'pending pull request' pending-error
    touch "$out"
  ''
