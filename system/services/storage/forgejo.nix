{
  lib,
  yumeami-lib,
  config,
  secrets,
  ...
}: let
  inherit (lib) mkEnableOption mkIf filterAttrs attrNames head;
  inherit (config.networking) hostName;
  cfg = config.forgejo;
  pgCfg = config.postgresql;

  resolveHostIP = yumeami-lib.resolveHostIP config.devices;

  port = 5300;

  dbHost =
    pgCfg.databases
    |> filterAttrs (host: dbs: lib.elem "forgejo" dbs)
    |> attrNames
    |> head
    |> resolveHostIP;
in {
  options.forgejo.enable = mkEnableOption "forgejo";

  config = mkIf cfg.enable {
    services.forgejo = {
      enable = true;

      stateDir = "/var/lib/forgejo";

      lfs.enable = true;

      database.type = mkIf (dbHost == hostName) "postgres";

      settings = {
        server = let
          url = "git.yumeami.sh";
        in {
          DOMAIN = url;
          ROOT_URL = "https://${url}/";
          HTTP_PORT = port;
          SSH_PORT = 2222;
          START_SSH_SERVER = true;
        };

        ui = {
          DEFAULT_THEME = "forgejo-dark";
          SHOW_USER_EMAIL = true;
        };

        database = {
          DB_TYPE = lib.mkForce "postgres";
          HOST = let
            host =
              pgCfg.databases
              |> filterAttrs (host: dbs: lib.elem "forgejo" dbs)
              |> attrNames
              |> head
              |> resolveHostIP;
          in "${host}:5600";
          NAME = "forgejo";
          USER = "forgejo";
          PASSWD = secrets.postgresql.forgejo;
        };

        service.DISABLE_REGISTRATION = true;

        actions.ENABLED = true;
      };
    };

    impermanence.folders = ["/var/lib/forgejo"];
  };
}
