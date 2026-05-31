{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf filterAttrs attrNames head elem;
  inherit (lib.${namespace}) getAttrByNamespace readJsonOrEmpty getIn resolveHostIP hostHasService flattenHostServices getServicePort;
  inherit (config.networking) hostName;

  pgCfg = getAttrByNamespace config "${namespace}.services.storage.postgresql";

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
  networkServices = flattenHostServices networkCfg.network-services;

  isEnabled = hostHasService networkCfg.network-services hostName "vault";
  port = getServicePort networkServices "vault" 5400;
in {
  config = mkIf isEnabled {
    services.vaultwarden = {
      enable = true;
      package = pkgs.vaultwarden-postgresql;
      dbBackend = "postgresql";

      environmentFile = config.sops.secrets."vaultwarden".path;

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

    systemd.services.vaultwarden = let
      dbHost =
        pgCfg.databases
        |> filterAttrs (host: dbs: elem "vaultwarden" dbs)
        |> attrNames
        |> head;
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
