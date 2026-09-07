{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkForce mkIf mkMerge;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService resolveDatabaseHost resolveDatabaseIP resolveServicePort waitForNetwork;
  inherit (config.networking) hostName;

  base = "${namespace}.services.apps.seafile";
  cfg = getAttrByNamespace config base;
  mariadbBase = "${namespace}.services.storage.mariadb";
  mariadbCfg = getAttrByNamespace config mariadbBase;
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  mariadbHost = resolveDatabaseHost mariadbCfg.databases "seafile";
  mariadbIp = resolveDatabaseIP networkCfg.devices mariadbCfg.databases hostName "seafile";
  proxysqlPort = 5650;
  port = resolveServicePort networkCfg.network-services "seafile" 8080;

  seahubSettings = pkgs.seahub.mkSettings {
    host = hostName;
    port = port;
    fileServerPort = port + 1;
    seafRoot = cfg.root;
  };

  isEnabled = hostHasService networkCfg.network-services hostName "seafile";
in {
  config = mkIf isEnabled {
    systemd.services.seahub = mkMerge [
      {
        description = "Seafile Server Web Frontend";

        wantedBy = ["seafile.target"];
        partOf = ["seafile.target"];
        after = ["seafile-server.service" "redis.service"];
        requires = ["seafile-server.service" "redis.service"];

        restartTriggers = [seahubSettings];

        environment = {
          DJANGO_SETTINGS_MODULE = "seahub.settings";
          CCNET_CONF_DIR = "${cfg.root}/ccnet";
          SEAFILE_CONF_DIR = "${cfg.root}/data";
          SEAFILE_CENTRAL_CONF_DIR = "${cfg.root}/conf";
          SEAFILE_RPC_PIPE_PATH = "/run/seafile";

          SEAHUB_LOG_DIR = "/var/log/seafile";

          SEAFILE_MYSQL_DB_HOST = mariadbIp;
          SEAFILE_MYSQL_DB_PORT = toString proxysqlPort;
          SEAFILE_MYSQL_DB_USER = "seafile";
          SEAFILE_MYSQL_DB_SEAFILE_DB_NAME = "seafile";
          SEAFILE_MYSQL_DB_CCNET_DB_NAME = "seafile-ccnet";
          SEAFILE_MYSQL_DB_SEAHUB_DB_NAME = "seafile-hub";

          REDIS_HOST = "127.0.0.1";
          REDIS_PORT = "6379";

          SEAFILE_SERVER_PROTOCOL = "http";
          SEAFILE_SERVER_HOSTNAME = hostName;

          INIT_SEAFILE_ADMIN_EMAIL = "c4patino@gmail.com";
        };

        serviceConfig = let
          inherit (config.users.users) seafile;
        in {
          User = seafile.name;
          Group = seafile.group;
          StateDirectory = "seafile";
          LogsDirectory = "seafile";
          ExecStart = ''
            ${lib.getExe pkgs.seahub} \
            --name seahub \
            --workers 4 \
            --log-level=info \
            --preload \
            --timeout=1200 \
            --limit-request-line=8190 \
            --bind 127.0.0.1:8000 \
            --bind 0.0.0.0:${toString port}
          '';

          EnvironmentFile = config.sops.secrets."environment-file/seafile".path;
        };

        preStart = ''
          mkdir -p ${cfg.root}/seahub/media
          for m in `find ${pkgs.seahub}/media/ -maxdepth 1 -not -name "avatars"`; do
            ln -sf $m ${cfg.root}/seahub/media/
          done

          if [ ! -e "${cfg.root}/.seahubSecret" ]; then
              (
                umask 377 &&
                ${lib.getExe pkgs.seahub.python3} ${pkgs.seahub}/tools/secret_key_generator.py > ${cfg.root}/.seahubSecret
              )
          fi

          install -D -m 644 ${seahubSettings} ${cfg.root}/conf/seahub_settings.py

          if [ ! -f "${cfg.root}/seahub-setup" ]; then
              install -D -t ${cfg.root}/seahub/media/avatars/ ${pkgs.seahub}/media/avatars/default.png
              install -D -t ${cfg.root}/seahub/media/avatars/groups ${pkgs.seahub}/media/avatars/groups/default.png
              ${pkgs.seahub}/manage.py migrate
              echo "${pkgs.seahub.version}-mysql" > "${cfg.root}/seahub-setup"
          fi

          if [ $(cat "${cfg.root}/seahub-setup" | cut -d"-" -f1) != "${pkgs.seahub.version}" ]; then
              ${pkgs.seahub}/manage.py migrate
              echo "${pkgs.seahub.version}-mysql" > "${cfg.root}/seahub-setup"
          fi

          for _ in $(seq 1 150); do
              if [ -S /run/seafile/seafile.sock ]; then
                  break
              fi
              sleep 0.2
          done
          if [ ! -S /run/seafile/seafile.sock ]; then
              echo "seaf-server RPC pipe /run/seafile/seafile.sock did not become ready" >&2
              exit 1
          fi

          if [ -n "$INIT_SEAFILE_ADMIN_EMAIL" ] || [ -n "$INIT_SEAFILE_ADMIN_PASSWORD" ]; then
              if [ -z "$INIT_SEAFILE_ADMIN_EMAIL" ] || [ -z "$INIT_SEAFILE_ADMIN_PASSWORD" ]; then
                  echo "INIT_SEAFILE_ADMIN_EMAIL and INIT_SEAFILE_ADMIN_PASSWORD must be set together" >&2
                  exit 1
              fi
              (
                umask 077 &&
                ${lib.getExe pkgs.seahub.python3} -c 'import json, os; env = os.environ; json.dump({"email": env["INIT_SEAFILE_ADMIN_EMAIL"], "password": env["INIT_SEAFILE_ADMIN_PASSWORD"]}, open(os.path.join(env["SEAFILE_CENTRAL_CONF_DIR"], "admin.txt"), "w"))'
              )
          fi

          if ! ${lib.getExe' pkgs.seahub "seahub-check-init-admin"}; then
              rm -f ${cfg.root}/conf/admin.txt
              exit 1
          fi
          rm -f ${cfg.root}/conf/admin.txt
        '';
      }
      waitForNetwork
      (mkIf (mariadbHost == hostName) {
        after = ["mysql.service" "proxysql.service"];
        requires = ["mysql.service" "proxysql.service"];
        serviceConfig.RestartSec = mkForce "1s";
      })
    ];
  };
}
