{ config, lib, ... }:
{
  imports = [ ../options.nix ];
  config.home.packages = lib.mkIf config.evak.shell.ssh.enable config.evak.shell.ssh.helperPackages;
}
