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

  isEnabled = hostHasService networkCfg.network-services hostName "seafile";
  mariadbHost = resolveDatabaseHost mariadbCfg.databases "seafile-ccnet";
  mariadbIp = resolveDatabaseIP networkCfg.devices mariadbCfg.databases hostName "seafile-ccnet";
  proxysqlPort = 5650;

  confDir = pkgs.seafile-server.mkConf {
    host = mariadbIp;
    port = proxysqlPort;
    fileServerPort = (resolveServicePort networkCfg.network-services "seafile" 8080) + 1;
  };
in {
  config = mkIf isEnabled {
    systemd.services.seafile-server = mkMerge [
      {
        description = "Seafile server";
        wantedBy = ["seafile.target"];
        partOf = ["seafile.target"];
        after = ["redis.service"];
        requires = ["redis.service"];
        environment = {
          SEAFILE_MYSQL_DB_HOST = mariadbIp;
          SEAFILE_MYSQL_DB_PORT = toString proxysqlPort;
          SEAFILE_MYSQL_DB_USER = "seafile";
          SEAFILE_MYSQL_DB_SEAFILE_DB_NAME = "seafile";
          SEAFILE_MYSQL_DB_CCNET_DB_NAME = "seafile-ccnet";
          SEAFILE_MYSQL_DB_SEAHUB_DB_NAME = "seafile-hub";
          REDIS_HOST = "127.0.0.1";
          REDIS_PORT = "6379";
        };

        serviceConfig = let
          inherit (config.users.users) seafile;
        in {
          User = seafile.name;
          Group = seafile.group;
          StateDirectory = "seafile";
          RuntimeDirectory = "seafile";
          LogsDirectory = "seafile";
          EnvironmentFile = config.sops.secrets."environment-file/seafile".path;
          ExecStart = ''
            ${lib.getExe pkgs.seafile-server} \
            --foreground \
            -F ${confDir} \
            -c ${cfg.root}/ccnet \
            -d ${cfg.root}/data \
            -l /var/log/seafile/server.log \
            -P /run/seafile/server.pid \
            -p /run/seafile
          '';
        };

        preStart = ''
          mkdir -p ${cfg.root}/data/library-template

          if [ ! -f "${cfg.root}/server-setup" ]; then
            export MYSQL_PWD="$SEAFILE_MYSQL_DB_PASSWORD"
            ${pkgs.mariadb.client}/bin/mariadb --user="$SEAFILE_MYSQL_DB_USER" --host=${mariadbIp} --port=${toString proxysqlPort} --database=seafile < ${pkgs.seafile-server}/share/seafile/sql/mysql/seafile.sql
            ${pkgs.mariadb.client}/bin/mariadb --user="$SEAFILE_MYSQL_DB_USER" --host=${mariadbIp} --port=${toString proxysqlPort} --database=seafile-ccnet < ${pkgs.seafile-server}/share/seafile/sql/mysql/ccnet.sql
            echo "${pkgs.seafile-server.version}-mysql" > "${cfg.root}/server-setup"
          fi
        '';
      }
      (mkIf (mariadbHost == hostName) {
        after = ["mysql.service" "proxysql.service"];
        requires = ["mysql.service" "proxysql.service"];
        serviceConfig.RestartSec = mkForce "1s";
      })
      waitForNetwork
    ];
  };
}
