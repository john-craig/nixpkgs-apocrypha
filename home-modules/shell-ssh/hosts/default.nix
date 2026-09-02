{ config, lib, ... }:
{
  imports = [ ../options.nix ];
  config.assertions = lib.optionals config.evak.shell.ssh.enable (
    lib.mapAttrsToList (name: host: {
      assertion = !host.enabled || host.hostname != null;
      message = "evak.shell.ssh.hosts.${name}.hostname must be set for an enabled host.";
    }) config.evak.shell.ssh.hosts
  );
}
