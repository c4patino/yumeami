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

  isEnabled = hostHasService networkCfg.network-services hostName "prowlarr";
  port = resolveServicePort networkCfg.network-services "prowlarr" 9696;
  dbHost = resolveDatabaseHost pgCfg.databases "prowlarr";
in {
  config = mkIf isEnabled {
    services.prowlarr = {
      enable = true;

      environmentFiles = [
        config.sops.secrets."environment-file/prowlarr".path
      ];

      settings = {
        server.port = port;
        postgres = {
          host = resolveDatabaseIP networkCfg.devices pgCfg.databases "prowlarr";
          port = 5600;
          user = "prowlarr";
          maindb = "prowlarr";
          logdb = "prowlarr-log";
        };
      };
    };

    systemd.services.prowlarr = let
      inherit (config.users.users) prowlarr;
    in
      mkMerge [
        {
          serviceConfig = {
            DynamicUser = mkForce false;
            User = prowlarr.name;
            Group = prowlarr.group;
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
      users.prowlarr = {
        isSystemUser = true;
        group = "prowlarr";
        extraGroups = ["jellyfin" "qbittorrent"];
      };

      groups.prowlarr = {};
    };

    sops.secrets."environment-file/prowlarr" = {};

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistDir config "prowlarr" "/var/lib/prowlarr")
    ];
  };
}
