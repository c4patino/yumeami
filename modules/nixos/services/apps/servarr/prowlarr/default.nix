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

  isEnabled = hostHasService networkCfg.network-services hostName "prowlarr";
  port = resolveServicePort networkCfg.network-services "prowlarr" 9696;
  dbHost = resolveDatabaseHost pgCfg.databases "prowlarr";
in {
  config = mkIf isEnabled {
    services.prowlarr = {
      enable = true;
      settings = {
        server.port = port;
        postgres = {
          host = resolveDatabaseIP networkCfg.devices pgCfg.databases "prowlarr";
          port = 5600;
          user = "prowlarr";
          maindb = "prowlarr";
          logdb = "prowlarr-log";
          password =
            "${inputs.self}/secrets/crypt/secrets.json"
            |> readJsonOrEmpty
            |> getIn "postgresql.prowlarr.password";
        };
      };
    };

    systemd.services.prowlarr = let
      prowlarrUser = config.users.users.prowlarr;
    in
      mkMerge [
        {
          serviceConfig = {
            DynamicUser = mkForce false;
            User = prowlarrUser.name;
            Group = prowlarrUser.group;
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

    ${namespace}.services.storage.impermanence.folders = let
      prowlarrUser = config.users.users.prowlarr;
    in [
      {
        directory = "/var/lib/prowlarr";
        user = prowlarrUser.name;
        group = prowlarrUser.group;
        mode = "700";
      }
    ];
  };
}
