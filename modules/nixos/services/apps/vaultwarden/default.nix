{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace readJsonOrEmpty getIn resolveDatabaseHost resolveDatabaseIP hostHasService resolveServicePort;
  inherit (config.networking) hostName;

  pgCfg = getAttrByNamespace config "${namespace}.services.storage.postgresql";

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  isEnabled = hostHasService networkCfg.network-services hostName "vault";
  port = resolveServicePort networkCfg.network-services "vault" 5400;
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

        DATABASE_URL = let
          secrets = readJsonOrEmpty "${inputs.self}/secrets/crypt/secrets.json";
          ip = resolveDatabaseIP networkCfg.devices pgCfg.databases "vaultwarden";
        in ''postgresql://vaultwarden:${getIn "postgresql.vaultwarden.password" secrets}@${ip}:5600/vaultwarden'';

        LOG_LEVEL = "Info";

        ROCKET_ADDRESS = "0.0.0.0";
        ROCKET_PORT = port;
        ROCKET_LOG = "critical";

        EXPERIMENTAL_CLIENT_FEATURE_FLAGS = "autofill-v2,extension-refresh,ssh-key-vault-item,ssh-agent";
      };
    };

    networking.firewall.allowedTCPPorts = [port];

    systemd.services.vaultwarden = let
      dbHost = resolveDatabaseHost pgCfg.databases "vaultwarden";
    in
      mkIf (dbHost == config.networking.hostName) {
        after = ["postgresql.service" "pgbouncer.service"];
        requires = ["postgresql.service" "pgbouncer.service"];
        serviceConfig = {
          RestartSec = "1s";
        };
      };

    sops.secrets = {
      "vaultwarden" = {};
    };
  };
}
