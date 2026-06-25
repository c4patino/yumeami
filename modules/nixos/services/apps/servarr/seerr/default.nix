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

  isEnabled = hostHasService networkCfg.network-services hostName "seerr";
  port = resolveServicePort networkCfg.network-services "seerr" 5055;
  dbHost = resolveDatabaseHost pgCfg.databases "seerr";
in {
  config = mkIf isEnabled {
    services.seerr = {
      enable = true;
      port = port;
      openFirewall = true;
    };

    systemd.services.seerr = let
      seerrUser = config.users.users.seerr;
      dbIp = resolveDatabaseIP networkCfg.devices pgCfg.databases "seerr";
      password =
        "${inputs.self}/secrets/crypt/secrets.json"
        |> readJsonOrEmpty
        |> getIn "postgresql.seerr.password";
    in
      mkMerge [
        {
          environment = {
            DB_TYPE = "postgres";
            DB_HOST = dbIp;
            DB_PORT = "5600";
            DB_USER = "seerr";
            DB_PASS = password;
            DB_NAME = "seerr";
          };

          serviceConfig = {
            DynamicUser = mkForce false;
            User = seerrUser.name;
            Group = seerrUser.group;
          };
        }
        (mkIf (dbHost == hostName) {
          after = ["postgresql.service" "pgbouncer.service"];
          requires = ["postgresql.service" "pgbouncer.service"];
          serviceConfig.RestartSec = "1s";
        })
      ];

    users = {
      users.seerr = {
        isSystemUser = true;
        group = "seerr";
      };

      groups.seerr = {};
    };

    ${namespace}.services.storage.impermanence.folders = let
      seerrUser = config.users.users.seerr;
    in [
      {
        directory = "/var/lib/seerr";
        user = seerrUser.name;
        group = seerrUser.group;
        mode = "700";
      }
    ];
  };
}
