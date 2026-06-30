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

  isEnabled = hostHasService networkCfg.network-services hostName "bazarr";
  port = resolveServicePort networkCfg.network-services "bazarr" 6767;
  dbHost = resolveDatabaseHost pgCfg.databases "bazarr";
in {
  config = mkIf isEnabled {
    services.bazarr = {
      enable = true;
      listenPort = port;
    };

    systemd.services.bazarr = let
      bazarrUser = config.users.users.bazarr;
      dbIp = resolveDatabaseIP networkCfg.devices pgCfg.databases "bazarr";
    in
      mkMerge [
        {
          environment = {
            POSTGRES_ENABLED = "true";
            POSTGRES_HOST = "${dbIp}";
            POSTGRES_PORT = "5600";
            POSTGRES_DATABASE = "bazarr";
            POSTGRES_USERNAME = "bazarr";
          };

          serviceConfig = {
            DynamicUser = mkForce false;
            User = bazarrUser.name;
            Group = bazarrUser.group;
            UMask = mkForce "0002";
            EnvironmentFile = config.sops.secrets."environment-file/bazarr".path;
          };
        }
        (mkIf (dbHost == hostName) {
          after = ["postgresql.service" "pgbouncer.service"];
          requires = ["postgresql.service" "pgbouncer.service"];
          serviceConfig.RestartSec = "1s";
        })
      ];

    users = {
      users.bazarr = {
        isSystemUser = true;
        group = "bazarr";
        extraGroups = ["jellyfin" "qbittorrent"];
      };

      groups.bazarr = {};
    };

    sops.secrets."environment-file/bazarr" = {};

    ${namespace}.services.storage.impermanence.folders = let
      bazarrUser = config.users.users.bazarr;
    in [
      {
        directory = "/var/lib/bazarr";
        user = bazarrUser.name;
        group = bazarrUser.group;
        mode = "700";
      }
    ];
  };
}
