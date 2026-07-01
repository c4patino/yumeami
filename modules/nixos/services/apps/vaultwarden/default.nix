{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge;
  inherit (lib.${namespace}) getAttrByNamespace resolveDatabaseHost resolveDatabaseIP hostHasService resolveServicePort mkPersistDir;
  inherit (config.networking) hostName;

  pgCfg = getAttrByNamespace config "${namespace}.services.storage.postgresql";

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  isEnabled = hostHasService networkCfg.network-services hostName "vault";
  port = resolveServicePort networkCfg.network-services "vault" 5400;

  dbHost = resolveDatabaseHost pgCfg.databases "vaultwarden";
  dbIp = resolveDatabaseIP networkCfg.devices pgCfg.databases "vaultwarden";
in {
  config = mkIf isEnabled {
    services.vaultwarden = {
      enable = true;
      package = pkgs.vaultwarden-postgresql;
      dbBackend = "postgresql";

      environmentFile = config.sops.secrets."vaultwarden".path;

      config = {
        DOMAIN = "https://vault.cpatino.com";

        SIGNUPS_ALLOWED = false;
        SIGNUPS_VERIFY = false;

        LOG_LEVEL = "Info";

        ROCKET_ADDRESS = "0.0.0.0";
        ROCKET_PORT = port;
        ROCKET_LOG = "critical";

        EXPERIMENTAL_CLIENT_FEATURE_FLAGS = "autofill-v2,extension-refresh,ssh-key-vault-item,ssh-agent";

        DATABASE_URL = "postgresql://";
      };
    };

    systemd.services.vaultwarden = mkMerge [
      {
        environment = {
          PGHOST = dbIp;
          PGPORT = "5600";
          PGDATABASE = "vaultwarden";
          PGUSER = "vaultwarden";
        };
      }
      (mkIf (dbHost == config.networking.hostName) {
        after = ["postgresql.service" "pgbouncer.service"];
        requires = ["postgresql.service" "pgbouncer.service"];
        serviceConfig.RestartSec = "1s";
      })
    ];

    sops.secrets."vaultwarden" = {};

    networking.firewall.allowedTCPPorts = [port];

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistDir config "vaultwarden" "/var/lib/vaultwarden")
    ];
  };
}
