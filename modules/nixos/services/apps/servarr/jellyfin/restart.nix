{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
  isEnabled = hostHasService networkCfg.network-services hostName "jellyfin";
in {
  config = mkIf isEnabled {
    systemd.services.jellyfin-restart = {
      description = "Restart Jellyfin";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.systemd}/bin/systemctl restart jellyfin.service";
      };
    };

    systemd.timers.jellyfin-restart = {
      description = "Nightly Jellyfin restart";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "*-*-* 03:00:00";
        RandomizedDelaySec = "5min";
        Persistent = true;
      };
    };
  };
}
