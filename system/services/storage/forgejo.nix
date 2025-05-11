{
  pkgs,
  lib,
  config,
  secrets,
  ...
}: let
  inherit (lib) mkEnableOption mkIf filterAttrs attrNames head;
  cfg = config.forgejo;
  pgCfg = config.postgresql;

  resolveHostIP = host:
    if builtins.hasAttr host config.devices
    then config.devices.${host}.IP
    else throw "Host '${host}' does not exist in the devices configuration.";

  port = 5300;
in {
  options.forgejo.enable = mkEnableOption "forgejo";

  config = mkIf cfg.enable {
    services.forgejo = {
      enable = true;

      stateDir = "/var/lib/forgejo";

      lfs.enable = true;

      settings = {
        server = {
          DOMAIN = "forgejo.yumeami.sh";
          ROOT_URL = "https://forgejo.yumeami.sh/";
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
