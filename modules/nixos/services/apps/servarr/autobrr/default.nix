{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkForce mkIf mkMerge;
  inherit (lib.${namespace}) getAttrByNamespace resolveDatabaseHost resolveDatabaseIP hostHasService resolveServicePort mkPersistDir;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
  pgCfg = getAttrByNamespace config "${namespace}.services.storage.postgresql";

  isEnabled = hostHasService networkCfg.network-services hostName "autobrr";
  port = resolveServicePort networkCfg.network-services "autobrr" 7474;
  dbHost = resolveDatabaseHost pgCfg.databases "autobrr";
in {
  config = mkIf isEnabled {
    services.autobrr = {
      enable = true;
      secretFile = config.sops.secrets."autobrr".path;

      settings = {
        host = "0.0.0.0";
        port = port;

        databaseType = "postgres";
        postgresHost = resolveDatabaseIP networkCfg.devices pgCfg.databases "autobrr";
        postgresPort = 5600;
        postgresDatabase = "autobrr";
        postgresUser = "autobrr";
        postgresSSLMode = "disable";
      };
    };

    systemd = {
      tmpfiles.settings."10-autobrr" = let
        configFormat = pkgs.formats.toml {};
        autobrrConfigFile = configFormat.generate "autobrr.toml" config.services.autobrr.settings;
      in {
        "/var/lib/autobrr/config.toml"."L+" = {
          argument = "${autobrrConfigFile}";
        };
      };

      services.autobrr = let
        inherit (config.users.users) autobrr;
      in
        mkMerge [
          {
            path = [
              (import ./check-autobrr-space.nix {inherit pkgs;})
            ];
            serviceConfig = {
              DynamicUser = mkForce false;
              User = autobrr.name;
              Group = autobrr.group;
              UMask = mkForce "0002";
              EnvironmentFile = config.sops.secrets."environment-file/autobrr".path;
            };
          }
          (mkIf (dbHost == hostName) {
            after = ["postgresql.service" "pgbouncer.service"];
            requires = ["postgresql.service" "pgbouncer.service"];
            serviceConfig.RestartSec = "1s";
          })
        ];
    };

    sops.secrets = {
      "autobrr" = {};
      "environment-file/autobrr" = {};
    };

    users = {
      users.autobrr = {
        isSystemUser = true;
        group = "autobrr";
        extraGroups = ["jellyfin" "qbittorrent"];
      };

      groups.autobrr = {};
    };

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistDir config "autobrr" "/var/lib/autobrr" "700")
    ];
  };
}
