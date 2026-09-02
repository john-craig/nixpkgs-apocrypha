{
  config,
  lib,
  pkgs,
}:
{
  packageFor = name: if pkgs ? ${name} then pkgs.${name} else null;
  tool = name: description: {
    enable = lib.mkEnableOption description;
    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = if pkgs ? ${name} then pkgs.${name} else null;
      description = "${description} package. Set this explicitly when it is absent from the pinned nixpkgs.";
    };
  };
  secretActivation =
    name: path: target:
    let
      script = ''
        if [ ! -r ${lib.escapeShellArg path} ]; then
          echo "evak.shell.cli.${name}: secret path ${path} is not readable" >&2
          exit 1
        fi
        install -m 0700 -d "$HOME/$(dirname ${lib.escapeShellArg target})"
        install -m 0600 ${lib.escapeShellArg path} "$HOME/${target}"
      '';
    in
    {
      after = [ "writeBoundary" ];
      data = script;
    };
}
