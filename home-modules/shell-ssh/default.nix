{ config, lib, pkgs, ... }:
let
  cfg = config.evak.shell.ssh;
  hostType = lib.types.submodule ({ ... }: {
    options = {
      hostname = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
      user = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
      port = lib.mkOption { type = lib.types.nullOr lib.types.port; default = null; };
      identityFile = lib.mkOption { type = lib.types.nullOr lib.types.path; default = null; };
      extraOptions = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = { }; };
      enabled = lib.mkOption { type = lib.types.bool; default = true; };
    };
  });
  matchBlocks = lib.mapAttrs (_: host: {
    inherit (host) hostname user port identityFile;
    extraOptions = host.extraOptions;
  }) (lib.filterAttrs (_: host: host.enabled) cfg.hosts);
in
{
  options.evak.shell.ssh = {
    enable = lib.mkEnableOption "portable SSH configuration";
    hosts = lib.mkOption { type = lib.types.attrsOf hostType; default = { }; description = "Explicit SSH host topology; hostname is required for enabled entries."; };
    agent = { enable = lib.mkOption { type = lib.types.bool; default = true; }; package = lib.mkOption { type = lib.types.package; default = pkgs.openssh; }; };
    extraConfig = lib.mkOption { type = lib.types.lines; default = ""; };
    helperPackages = lib.mkOption { type = lib.types.listOf lib.types.package; default = [ ]; description = "Explicit helper packages for specialized SSH entries."; };
  };
  config = {
    assertions = lib.optionals cfg.enable (lib.mapAttrsToList (name: host: {
      assertion = !host.enabled || host.hostname != null;
      message = "evak.shell.ssh.hosts.${name}.hostname must be set for an enabled host.";
    }) cfg.hosts);
    services.ssh-agent = lib.mkIf (cfg.enable && cfg.agent.enable) { enable = true; package = cfg.agent.package; };
    home.packages = lib.mkIf cfg.enable cfg.helperPackages;
    programs.ssh = lib.mkIf cfg.enable { enable = true; matchBlocks = matchBlocks; extraConfig = cfg.extraConfig; };
  };
}
