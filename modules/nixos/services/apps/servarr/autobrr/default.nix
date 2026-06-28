{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkForce mkIf mkMerge;
  inherit (lib.${namespace}) getAttrByNamespace resolveDatabaseHost resolveDatabaseIP readJsonOrEmpty getIn hostHasService resolveServicePort;
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
        postgresPass =
          "${inputs.self}/secrets/crypt/secrets.json"
          |> readJsonOrEmpty
          |> getIn "postgresql.autobrr.password";
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
        autobrrUser = config.users.users.autobrr;
      in
        mkMerge [
          {
            path = [
              (import ./check-autobrr-space.nix {inherit pkgs;})
            ];
            serviceConfig = {
              DynamicUser = mkForce false;
              User = autobrrUser.name;
              Group = autobrrUser.group;
              UMask = mkForce "0002";
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
      "autobrr" = {
        owner = config.users.users.autobrr.name;
        group = config.users.users.autobrr.group;
      };
    };

    users = {
      users.autobrr = {
        isSystemUser = true;
        group = "autobrr";
        extraGroups = ["jellyfin" "qbittorrent"];
      };

      groups.autobrr = {};
    };

    ${namespace}.services.storage.impermanence.folders = let
      autobrrUser = config.users.users.autobrr;
    in [
      {
        directory = "/var/lib/autobrr";
        user = autobrrUser.name;
        group = autobrrUser.group;
        mode = "700";
      }
    ];
  };
}
