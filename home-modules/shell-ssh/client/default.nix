{ config, lib, ... }:
{
  imports = [ ../options.nix ];
  config = lib.mkIf config.evak.shell.ssh.enable {
    programs.ssh = {
      enable = true;
      matchBlocks = lib.mapAttrs (_: host: {
        inherit (host)
          hostname
          user
          port
          identityFile
          ;
        extraOptions = host.extraOptions;
      }) (lib.filterAttrs (_: host: host.enabled) config.evak.shell.ssh.hosts);
      extraConfig = config.evak.shell.ssh.extraConfig;
    };
  };
}
