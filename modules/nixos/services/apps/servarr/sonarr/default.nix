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

  isEnabled = hostHasService networkCfg.network-services hostName "sonarr";
  port = resolveServicePort networkCfg.network-services "sonarr" 8989;
  dbHost = resolveDatabaseHost pgCfg.databases "sonarr";
in {
  config = mkIf isEnabled {
    services.sonarr = {
      enable = true;

      environmentFiles = [
        config.sops.secrets."environment-file/sonarr".path
      ];

      settings = {
        server.port = port;
        postgres = {
          host = resolveDatabaseIP networkCfg.devices pgCfg.databases "sonarr";
          port = 5600;
          user = "sonarr";
          maindb = "sonarr";
          logdb = "sonarr-log";
        };
      };
    };

    systemd.services.sonarr = let
      inherit (config.users.users) sonarr;
    in
      mkMerge [
        {
          serviceConfig = {
            DynamicUser = mkForce false;
            User = sonarr.name;
            Group = sonarr.group;
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
      users.sonarr = {
        isSystemUser = true;
        group = "sonarr";
        extraGroups = ["jellyfin" "qbittorrent"];
      };

      groups.sonarr = {};
    };

    sops.secrets."environment-file/sonarr" = {};

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistDir config "sonarr" "/var/lib/sonarr")
    ];
  };
}
