{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkForce mkIf mkMerge;
  inherit (lib.${namespace}) getAttrByNamespace resolveDatabaseHost resolveDatabaseIP hostHasService resolveServicePort mkPersistDir;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
  pgCfg = getAttrByNamespace config "${namespace}.services.storage.postgresql";

  isEnabled = hostHasService networkCfg.network-services hostName "lidarr";
  port = resolveServicePort networkCfg.network-services "lidarr" 8686;
  dbHost = resolveDatabaseHost pgCfg.databases "lidarr";
in {
  config = mkIf isEnabled {
    services.lidarr = {
      enable = true;

      environmentFiles = [
        config.sops.secrets."environment-file/lidarr".path
      ];

      settings = {
        server.port = port;
        postgres = {
          host = resolveDatabaseIP networkCfg.devices pgCfg.databases "lidarr";
          port = 5600;
          user = "lidarr";
          maindb = "lidarr";
          logdb = "lidarr-log";
        };
      };
    };

    systemd.services.lidarr = let
      inherit (config.users.users) lidarr;
    in
      mkMerge [
        {
          serviceConfig = {
            DynamicUser = mkForce false;
            User = lidarr.name;
            Group = lidarr.group;
            UMask = mkForce "0002";
          };
        }
        (mkIf (dbHost == hostName) {
          after = ["postgresql.service" "pgbouncer.service"];
          requires = ["postgresql.service" "pgbouncer.service"];
          serviceConfig.RestartSec = "1s";
        })
      ];

    users = {
      users.lidarr = {
        isSystemUser = true;
        group = "lidarr";
        extraGroups = ["jellyfin" "qbittorrent"];
      };

      groups.lidarr = {};
    };

    sops.secrets."environment-file/lidarr" = {};

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistDir config "lidarr" "/var/lib/lidarr" "700")
    ];
  };
}
