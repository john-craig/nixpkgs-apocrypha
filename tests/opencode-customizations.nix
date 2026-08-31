{ pkgs ? import <nixpkgs> { } }:
let
  eval = enable: pkgs.lib.evalModules {
    specialArgs = { inherit pkgs; };
    modules = [
      ({ lib, ... }: {
        options.home.file = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule ({ lib, ... }: {
            options.source = lib.mkOption { type = lib.types.path; };
          }));
          default = { };
        };
        config.evak.opencode.enable = enable;
      })
      ./../home-modules/opencode
    ];
  };

  enabled = (eval true).config.home.file;
  disabled = (eval false).config.home.file;
in
assert disabled == { };
pkgs.runCommand "opencode-customizations-test" {
  nativeBuildInputs = [ pkgs.jq ];
} ''
  jq -e '
    .plugin == [
      "@mohak34/opencode-notifier@0.1.36",
      "opencode-codex-quota@1.0.1",
      "opencode-quotes-plugin/tui"
    ]
  ' ${enabled.".config/opencode/opencode.json".source} >/dev/null

  jq -e '
    .theme == "synthwave-84" and
    ."$schema" == "https://opencode.ai/tui.json"
  ' ${enabled.".config/opencode/tui.json".source} >/dev/null

  jq -e '
    ."$schema" == "https://opencode.ai/theme.json" and
    .theme.primary == "pink" and
    .theme.accent == "cyan" and
    .theme.background == "background"
  ' ${enabled.".config/opencode/themes/synthwave-84.json".source} >/dev/null

  jq -e '
    .sound == true and
    .notification == true and
    .suppressWhenFocused == false and
    .minDuration == 10 and
    .command.enabled == true and
    .command.minDuration == 10 and
    .command.args == ["{event}", "{message}"] and
    (.sounds.complete | endswith("ding.mp3"))
  ' ${enabled.".config/opencode/opencode-notifier.json".source} >/dev/null

  notifier_command=$(jq -r .command.path ${enabled.".config/opencode/opencode-notifier.json".source})
  grep -q gotify "$notifier_command"
  grep -q 'hyprctl notify' "$notifier_command"
  test -s ${enabled.".config/opencode/ding.mp3".source}
  touch $out
''
