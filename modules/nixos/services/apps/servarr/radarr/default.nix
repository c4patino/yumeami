{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkForce mkIf mkMerge;
  inherit (lib.${namespace}) getAttrByNamespace resolveDatabaseHost resolveDatabaseIP hostHasService resolveServicePort;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
  pgCfg = getAttrByNamespace config "${namespace}.services.storage.postgresql";

  isEnabled = hostHasService networkCfg.network-services hostName "radarr";
  port = resolveServicePort networkCfg.network-services "radarr" 7878;
  dbHost = resolveDatabaseHost pgCfg.databases "radarr";
in {
  config = mkIf isEnabled {
    services.radarr = {
      enable = true;

      environmentFiles = [
        config.sops.secrets."environment-file/radarr".path
      ];

      settings = {
        server.port = port;
        postgres = {
          host = resolveDatabaseIP networkCfg.devices pgCfg.databases "radarr";
          port = 5600;
          user = "radarr";
          maindb = "radarr";
          logdb = "radarr-log";
        };
      };
    };

    systemd.services.radarr = let
      radarrUser = config.users.users.radarr;
    in
      mkMerge [
        {
          serviceConfig = {
            DynamicUser = mkForce false;
            User = radarrUser.name;
            Group = radarrUser.group;
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
      users.radarr = {
        isSystemUser = true;
        group = "radarr";
        extraGroups = ["jellyfin" "qbittorrent"];
      };

      groups.radarr = {};
    };

    sops.secrets."environment-file/radarr" = {};

    ${namespace}.services.storage.impermanence.folders = let
      radarrUser = config.users.users.radarr;
    in [
      {
        directory = "/var/lib/radarr";
        user = radarrUser.name;
        group = radarrUser.group;
        mode = "700";
      }
    ];
  };
}
