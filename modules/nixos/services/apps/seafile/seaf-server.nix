{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkForce mkIf mkMerge;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService resolveDatabaseHost resolveDatabaseIP waitForNetwork;
  inherit (config.networking) hostName;

  base = "${namespace}.services.storage.mariadb";
  mariadbCfg = getAttrByNamespace config base;
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  isEnabled = hostHasService networkCfg.network-services hostName "seafile";
  mariadbHost = resolveDatabaseHost mariadbCfg.databases "seafile-ccnet";
  mariadbIp = resolveDatabaseIP networkCfg.devices mariadbCfg.databases hostName "seafile-ccnet";
  proxysqlPort = 5650;

  seafRoot = "/var/lib/seafile";
  ccnetDir = "${seafRoot}/ccnet";
  seafileEnvFile = config.sops.secrets."environment-file/seafile".path;

  confDir = pkgs.runCommand "seafile-conf" {} ''
    mkdir -p $out
    cat > $out/ccnet.conf << EOF
    [Database]
    ENGINE = mysql
    HOST = ${mariadbIp}
    PORT = ${toString proxysqlPort}
    DB = seafile-ccnet
    CONNECTION_CHARSET = utf8
    EOF

    cat > $out/seafile.conf << EOF
    [database]
    type = mysql
    host = ${mariadbIp}
    port = ${toString proxysqlPort}
    db_name = seafile
    connection_charset = utf8

    [fileserver]
    port = 8082
    host = ipv4:127.0.0.1
    EOF
  '';
in {
  config = mkIf isEnabled {
    systemd.services.seaf-server = mkMerge [
      {
        description = "Seafile server";
        wantedBy = ["seafile.target"];
        partOf = ["seafile.target"];
        environment = {
          SEAFILE_MYSQL_DB_HOST = mariadbIp;
          SEAFILE_MYSQL_DB_PORT = toString proxysqlPort;
          SEAFILE_MYSQL_DB_USER = "seafile";
          SEAFILE_MYSQL_DB_SEAFILE_DB_NAME = "seafile";
          SEAFILE_MYSQL_DB_CCNET_DB_NAME = "seafile-ccnet";
          SEAFILE_MYSQL_DB_SEAHUB_DB_NAME = "seafile-hub";
        };
        serviceConfig = {
          User = "seafile";
          Group = "seafile";
          StateDirectory = "seafile";
          RuntimeDirectory = "seafile";
          LogsDirectory = "seafile";
          ConfigurationDirectory = "seafile";
          EnvironmentFile = seafileEnvFile;
          ExecStart = ''
            ${lib.getExe pkgs.seafile-server} \
            --foreground \
            -F ${confDir} \
            -c ${ccnetDir} \
            -d ${seafRoot}/data \
            -l /var/log/seafile/server.log \
            -P /run/seafile/server.pid \
            -p /run/seafile
          '';
        };
        preStart = ''
          mkdir -p ${seafRoot}/data/library-template
          if [ ! -f "${seafRoot}/server-setup" ]; then
            ${pkgs.mariadb.client}/bin/mysql --host=${mariadbIp} --port=${toString proxysqlPort} --database=seafile-ccnet < ${pkgs.seafile-server}/share/seafile/sql/mysql/ccnet.sql
            ${pkgs.mariadb.client}/bin/mysql --host=${mariadbIp} --port=${toString proxysqlPort} --database=seafile < ${pkgs.seafile-server}/share/seafile/sql/mysql/seafile.sql
            echo "${pkgs.seafile-server.version}-mysql" > "${seafRoot}/server-setup"
          fi
        '';
      }
      (mkIf (mariadbHost == hostName) {
        after = ["mysql.service"];
        requires = ["mysql.service"];
        serviceConfig.RestartSec = mkForce "1s";
      })
      waitForNetwork
    ];
  };
}
