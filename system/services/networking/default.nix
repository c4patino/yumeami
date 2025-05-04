{
  pkgs,
  lib,
  config,
  ...
}: let
  nodeIP = node:
    if builtins.hasAttr node config.devices
    then config.devices.${node}.IP
    else builtins.throw "Host '${node}' does not exist in the devices configuration.";

  ip = lib.optionalString (config.unbound.dnsHost != null) "${nodeIP config.unbound.dnsHost}";

  dns = lib.concatStringsSep " " [ip "1.1.1.1" "8.8.8.8" "100.100.100.100"];
in {
  options = {
    network-manager.enable = lib.mkEnableOption "network manager";
  };

  imports = [
    ./blocky.nix
    ./httpd.nix
    ./tailscale.nix
    ./unbound.nix
  ];

  config = lib.mkIf config.network-manager.enable {
    environment.systemPackages = with pkgs; [
      networkmanagerapplet
    ];

    networking.resolvconf.enable = true;
    networking.resolvconf.extraConfig = ''
      ${lib.optionalString (config.unbound.dnsHost != null) "name_servers=${nodeIP config.unbound.dnsHost}"}
      search_domains="tail8b9fd9.ts.net"
      name_servers="${dns}"
    '';

    networking.networkmanager.enable = true;
  };
}
