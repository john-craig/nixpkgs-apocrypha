{pkgs}: let
  fakeImplementor = pkgs.writeShellScriptBin "openspec-implementor" ''
    set -euo pipefail
    upstream=""
    status_file=""
    while (($# > 0)); do
      case "$1" in
        --upstream) upstream="$2"; shift 2 ;;
        --status-file) status_file="$2"; shift 2 ;;
        *) shift ;;
      esac
    done
    printf '%s\n' "$upstream" >> "$SCHEDULER_CALL_LOG"
    case "$upstream" in
      https://github.com/owner/repo-a.git)
        printf '%s\n' no-work > "$status_file"
        printf '%s\n' 'No active OpenSpec changes found.'
        exit 0
        ;;
      https://github.com/owner/repo-b.git|https://github.com/owner/repo-c.git)
        if [[ ''${FAIL_IMPLEMENTOR:-false} == true ]]; then
          printf '%s\n' failure > "$status_file"
          printf '%s\n' 'simulated implementation failure' >&2
          exit 7
        fi
        printf '%s\n' success > "$status_file"
        printf 'https://github.com/owner/repo/pull/1\n'
        ;;
    esac
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
          options.systemd.user.services = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = {};
          };
          options.systemd.user.timers = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = {};
          };
        })
        ./../home-modules/project-manager/automated-development-workflows/implementor-scheduler
        ({...}: {
          config.evak.project-manager.automated-development-workflows.implementor-scheduler = {
            enable = enabled;
            implementorPackage = fakeImplementor;
            retryOnFailure = true;
            stateFile = "/build/openspec-implementor-scheduler/state";
            lockFile = "/build/openspec-implementor-scheduler/lock";
            upstreams = [
              {url = "https://github.com/owner/repo-a.git";}
              {url = "https://github.com/owner/repo-b.git";}
              {url = "https://github.com/owner/repo-c.git";}
            ];
          };
        })
        extra
      ];
    };
  disabled = eval false {};
  enabled = eval true {};
  scheduler = builtins.head enabled.config.home.packages;
  service = enabled.config.systemd.user.services."evak-openspec-implementor-scheduler";
  timer = enabled.config.systemd.user.timers."evak-openspec-implementor-scheduler";
in
assert disabled.config.home.packages == [];
assert disabled.config.systemd.user.services == {};
assert builtins.length enabled.config.home.packages == 1;
assert service.Service.Type == "oneshot";
assert timer.Timer.OnBootSec == "6h";
assert timer.Timer.OnUnitActiveSec == "6h";
assert timer.Timer.Persistent == false;
pkgs.runCommand "openspec-implementor-scheduler-test" {
  nativeBuildInputs = [scheduler fakeImplementor pkgs.gnugrep];
} ''
  set -euo pipefail
  mkdir -p state runtime
  export XDG_STATE_HOME="$PWD/state"
  export XDG_RUNTIME_DIR="$PWD/runtime"
  export SCHEDULER_CALL_LOG="$PWD/calls"
  : > "$SCHEDULER_CALL_LOG"
  cursor_file=/build/openspec-implementor-scheduler/state

  openspec-implementor-scheduler > first-run
  test "$(sed -n '1p' "$SCHEDULER_CALL_LOG")" = https://github.com/owner/repo-a.git
  test "$(sed -n '2p' "$SCHEDULER_CALL_LOG")" = https://github.com/owner/repo-b.git
  test "$(grep -o 'next_index=[0-9]*' "$cursor_file")" = next_index=2

  openspec-implementor-scheduler > second-run
  test "$(sed -n '3p' "$SCHEDULER_CALL_LOG")" = https://github.com/owner/repo-c.git
  test "$(grep -o 'next_index=[0-9]*' "$cursor_file")" = next_index=0

  export FAIL_IMPLEMENTOR=true
  if openspec-implementor-scheduler > failure-run 2>&1; then
    exit 1
  fi
  test "$(sed -n '4p' "$SCHEDULER_CALL_LOG")" = https://github.com/owner/repo-a.git
  test "$(sed -n '5p' "$SCHEDULER_CALL_LOG")" = https://github.com/owner/repo-b.git
  test "$(grep -o 'next_index=[0-9]*' "$cursor_file")" = next_index=1

  unset FAIL_IMPLEMENTOR
  openspec-implementor-scheduler > retry-run
  test "$(sed -n '6p' "$SCHEDULER_CALL_LOG")" = https://github.com/owner/repo-b.git
  touch "$out"
''
