{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkForce;
  inherit (lib.${namespace}) getAttrByNamespace resolveDatabaseHost resolveDatabaseIP hostHasService resolveServicePort mkPersistDir;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
  pgCfg = getAttrByNamespace config "${namespace}.services.storage.postgresql";

  isEnabled = hostHasService networkCfg.network-services hostName "git";
  port = resolveServicePort networkCfg.network-services "git" 5300;
in {
  config = mkIf isEnabled {
    services.forgejo = {
      enable = true;
      package = pkgs.forgejo;

      stateDir = "/var/lib/forgejo";

      lfs.enable = true;

      database.type = "postgres";

      secrets.database = {
        PASSWD = config.sops.secrets."forgejo/db".path;
      };

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
          HOST = mkForce "${resolveDatabaseIP networkCfg.devices pgCfg.databases "forgejo"}:5600";
          NAME = "forgejo";
          USER = "forgejo";
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
      mkIf (resolveDatabaseHost pgCfg.databases "forgejo" == hostName) {
        after = ["postgresql.service" "pgbouncer.service"];
        requires = ["postgresql.service" "pgbouncer.service"];
        serviceConfig = {
          RestartSec = "5s";
        };
      };

    sops.secrets."forgejo/db" = {};

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistDir config "forgejo" "/var/lib/forgejo")
    ];
  };
}
