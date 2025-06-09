{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.services.apps.vaultwarden";
  cfg = getAttrByNamespace config base;
  pgCfg = getAttrByNamespace config "${namespace}.services.storage.postgresql";
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  port = 5400;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "vaultwarden";
    };

  config = mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      package = pkgs.vaultwarden-postgresql;
      dbBackend = "postgresql";
      config = {
        DOMAIN = "https://vault.yumeami.sh";

        SIGNUPS_ALLOWED = false;
        SIGNUPS_VERIFY = false;

        DATABASE_URL = let
          secrets = readJsonOrEmpty "${inputs.self}/secrets/crypt/secrets.json";
          ip =
            pgCfg.databases
            |> filterAttrs (host: dbs: elem "vaultwarden" dbs)
            |> attrNames
            |> head
            |> resolveHostIP networkCfg.devices;
        in ''postgresql://vaultwarden:${getIn "postgresql.vaultwarden" secrets}@${ip}:5600/vaultwarden'';

        LOG_LEVEL = "Info";

        ROCKET_ADDRESS = "0.0.0.0";
        ROCKET_PORT = port;
        ROCKET_LOG = "critical";

        EXPERIMENTAL_CLIENT_FEATURE_FLAGS = "autofill-v2,extension-refresh,ssh-key-vault-item,ssh-agent";
      };
    };

    networking.firewall.allowedTCPPorts = [port];
  };
}
