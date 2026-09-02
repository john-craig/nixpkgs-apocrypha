{ config, lib, ... }:
{
  imports = [ ../options.nix ];
  config = lib.mkIf (config.evak.shell.ssh.enable && config.evak.shell.ssh.agent.enable) {
    services.ssh-agent = {
      enable = true;
      package = config.evak.shell.ssh.agent.package;
    };
  };
}
