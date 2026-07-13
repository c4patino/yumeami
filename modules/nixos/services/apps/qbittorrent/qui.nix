{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge;
  inherit (lib.${namespace}) getAttrByNamespace resolveDatabaseHost hostHasService resolveServicePort resolveDatabaseIP mkPersistDir;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
  pgCfg = getAttrByNamespace config "${namespace}.services.storage.postgresql";

  isEnabled = hostHasService networkCfg.network-services hostName "qbittorrent";
  port = resolveServicePort networkCfg.network-services "qbittorrent" 9000;
  dbHost = resolveDatabaseHost pgCfg.databases "qui";
in {
  config = mkIf isEnabled {
    services.qui = {
      enable = true;
      openFirewall = false;
      package = pkgs.qui;
      secretFile = config.sops.secrets."qui".path;

      settings = {
        host = "0.0.0.0";
        port = port;

        databaseEngine = "postgres";
        databaseHost = resolveDatabaseIP networkCfg.devices pgCfg.databases "qui";
        databasePort = 5600;
        databaseName = "qui";
        databaseUser = "qui";
      };
    };

    systemd.services.qui = mkMerge [
      {
        serviceConfig.EnvironmentFile = config.sops.secrets."environment-file/qui".path;
      }
      (mkIf (dbHost == hostName) {
        after = ["postgresql.service"];
        requires = ["postgresql.service"];
        serviceConfig.RestartSec = "1s";
      })
    ];

    users = {
      users.qui = {
        isSystemUser = true;
        group = "qui";
        extraGroups = ["qbittorrent"];
      };

      groups.qui = {};
    };

    sops.secrets = {
      "environment-file/qui" = {};
      "qui" = {};
    };

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistDir config "qui" "/var/lib/qui" "700")
    ];
  };
}
