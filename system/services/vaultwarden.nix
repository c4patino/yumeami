{
  pkgs,
  lib,
  yumeami-lib,
  config,
  secrets,
  ...
}: let
  inherit (lib) mkIf mkEnableOption filterAttrs head;
  cfg = config.vaultwarden;
  pgCfg = config.postgresql;

  resolveHostIP = yumeami-lib.resolveHostIP config.devices;

  port = 5400;
in {
  options.vaultwarden.enable = mkEnableOption "vaultwarden";

  config = mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      package = pkgs.vaultwarden-postgresql;
      dbBackend = "postgresql";
      config = {
        DOMAIN = "http://vaultwarden.yumeami.sh";

        SIGNUPS_ALLOWED = false;
        SIGNUPS_VERIFY = false;

        DATABASE_URL = let
          ip =
            pgCfg.databases
            |> filterAttrs (host: dbs: lib.elem "vaultwarden" dbs)
            |> lib.attrNames
            |> head
            |> resolveHostIP;
        in ''postgresql://vaultwarden:${secrets.postgresql.vaultwarden}@${ip}:5600/vaultwarden'';

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
