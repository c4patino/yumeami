{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkForce mkIf mkMerge;
  inherit (lib.${namespace}) getAttrByNamespace resolveDatabaseHost resolveDatabaseIP readJsonOrEmpty getIn hostHasService resolveServicePort;
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
      settings = {
        server.port = port;
        postgres = {
          host = resolveDatabaseIP networkCfg.devices pgCfg.databases "sonarr";
          port = 5600;
          user = "sonarr";
          maindb = "sonarr";
          logdb = "sonarr-log";
          password =
            "${inputs.self}/secrets/crypt/secrets.json"
            |> readJsonOrEmpty
            |> getIn "postgresql.sonarr.password";
        };
      };
    };

    systemd.services.sonarr = let
      sonarrUser = config.users.users.sonarr;
    in
      mkMerge [
        {
          serviceConfig = {
            DynamicUser = mkForce false;
            User = sonarrUser.name;
            Group = sonarrUser.group;
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

    ${namespace}.services.storage.impermanence.folders = let
      sonarrUser = config.users.users.sonarr;
    in [
      {
        directory = "/var/lib/sonarr";
        user = sonarrUser.name;
        group = sonarrUser.group;
        mode = "700";
      }
    ];
  };
}
