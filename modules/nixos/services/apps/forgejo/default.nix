{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf filterAttrs attrNames head mkForce;
  inherit (lib.${namespace}) getAttrByNamespace resolveHostIP readJsonOrEmpty getIn hostHasService flattenHostServices getServicePort;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
  networkServices = flattenHostServices networkCfg.network-services;

  pgCfg = getAttrByNamespace config "${namespace}.services.storage.postgresql";
  dbHost =
    pgCfg.databases
    |> filterAttrs (host: dbs: lib.elem "forgejo" dbs)
    |> attrNames
    |> head;

  isEnabled = hostHasService networkCfg.network-services hostName "git";
  port = getServicePort networkServices "git" 5300;
in {
  config = mkIf isEnabled {
    services.forgejo = {
      enable = true;
      package = pkgs.forgejo;

      stateDir = "/var/lib/forgejo";

      lfs.enable = true;

      database.type = mkIf (dbHost == hostName) "postgres";

      settings = {
        actions.ENABLED = true;

        badges.ENABLED = true;

        "cron.git_gc_repos" = {
          ENABLED = true;
          RUN_AT_START = true;
          SCHEDULE = "@every 48h";
          TIMEOUT = "5m";
        };

        "cron.archive_cleanup" = {
          ENABLED = true;
          RUN_AT_START = true;
          SCHEDULE = "@every 2h";
          OLDER_THAN = "6h";
        };

        database = {
          DB_TYPE = mkForce "postgres";
          HOST = mkForce "${resolveHostIP networkCfg.devices dbHost}:5600";
          NAME = "forgejo";
          USER = "forgejo";
          PASSWD =
            "${inputs.self}/secrets/crypt/secrets.json"
            |> readJsonOrEmpty
            |> getIn "postgresql.forgejo.password";
        };

        "git.timeout" = {
          DEFAULT = 360;
          CLONE = 300;
          GC = 60;
          GREP = 2;
          MIGRATE = 3600;
          MIRROR = 3600;
          PULL = 300;
        };

        repository = {
          ENABLE_PUSH_CREATE_USER = true;
          ENABLE_PUSH_CREATE_ORG = true;
          DEFAULT_PUSH_CREATE_PRIVATE = true;
        };

        ui = {
          DEFAULT_THEME = "forgejo-dark";
          SHOW_USER_EMAIL = true;
        };

        server = let
          url = "git.cpatino.com";
        in {
          DOMAIN = url;
          ROOT_URL = "https://${url}/";
          HTTP_PORT = port;
          SSH_DOMAIN = "git.yumeami.sh";
        };

        service.DISABLE_REGISTRATION = true;

        webhook.ALLOWED_HOST_LIST = "external,loopback";
      };
    };

    systemd.services.forgejo = let
      inherit (config.networking) hostName;
    in
      mkIf (dbHost == hostName) {
        after = ["postgresql.service" "pgbouncer.service"];
        requires = ["postgresql.service" "pgbouncer.service"];
        serviceConfig = {
          RestartSec = "1s";
        };
      };

    ${namespace}.services.storage.impermanence.folders = ["/var/lib/forgejo"];
  };
}
