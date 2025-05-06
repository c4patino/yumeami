{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf optionalString concatStringsSep;

  cfg = config.network-manager;
  ubCfg = config.unbound;

  resolveHostIP = node:
    if builtins.hasAttr node config.devices
    then config.devices.${node}.IP
    else builtins.throw "Host '${node}' does not exist in the devices configuration.";

  ip = optionalString (config.unbound.dnsHost != null) "${resolveHostIP config.unbound.dnsHost}";

  dns = [ip "1.1.1.1" "8.8.8.8" "100.100.100.100"] |> concatStringsSep " ";
in {
  options.network-manager.enable = mkEnableOption "network manager";

  imports = [
    ./blocky.nix
    ./httpd.nix
    ./tailscale.nix
    ./unbound.nix
  ];

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      networkmanagerapplet
    ];

    networking.resolvconf.enable = true;
    networking.resolvconf.extraConfig = ''
      ${optionalString (ubCfg.dnsHost != null) "name_servers=${resolveHostIP ubCfg.dnsHost}"}
      search_domains="tail8b9fd9.ts.net"
      name_servers="${dns}"
    '';

    networking.networkmanager.enable = true;

    impermanence.folders = ["/etc/NetworkManager/system-connections"];
  };
}
