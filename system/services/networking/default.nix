{
  pkgs,
  lib,
  config,
  yumeami-lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf concatStringsSep;
  cfg = config.network-manager;
  ubCfg = config.unbound;

  resolveHostIP = yumeami-lib.resolveHostIP config.devices;
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

    networking = {
      resolvconf.enable = true;
      resolvconf.extraConfig = let
        ip =
          if ubCfg.dnsHost != null
          then resolveHostIP ubCfg.dnsHost
          else null;
        allDns = lib.optional (ip != null) ip ++ ["1.1.1.1" "8.8.8.8" "100.100.100.100"];
      in ''
        ${lib.optionalString (ip != null) "name_servers=${ip}"}
        search_domains="tail8b9fd9.ts.net"
        name_servers="${concatStringsSep " " allDns}"
      '';

      networkmanager.enable = true;
    };

    impermanence.folders = ["/etc/NetworkManager/system-connections"];
  };
}
