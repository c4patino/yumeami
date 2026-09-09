{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) getAttr hasAttr mkIf;
  inherit (lib.${namespace}) getAttrByNamespace getIn mkDatabaseUtils mkPersistRootDir readJsonOrEmpty resolveDatabaseIP;
  inherit (config.networking) hostName;
  base = "${namespace}.services.storage.mariadb";
  cfg = getAttrByNamespace config base;
  secrets = readJsonOrEmpty "${inputs.self}/secrets/crypt/mariadb.json";
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  port = 5650;
  adminPort = 5652;
  mariadbPort = 5651;

  configFile = let
    hostDatabases = getAttr hostName cfg.databases;
    db = mkDatabaseUtils hostDatabases;
  in
    (pkgs.formats.libconfig {}).generate "proxysql.cnf" {
      admin_variables = {
        admin_credentials = "admin:admin";
        mysql_ifaces = "0.0.0.0:${toString adminPort}";
        refresh_interval = 2000;
      };

      mysql_variables = {
        threads = 4;
        max_connections = 2048;
        default_max_latency_ms = 1000;
        servers_stats = true;
        connection_max_age_ms = 0;
        connect_retries_on_failure = 10;
        have_ssl = false;
        mysql_ifaces = "0.0.0.0:${toString port}";
      };

      mysql_servers = [
        {
          address = resolveDatabaseIP networkCfg.devices cfg.databases (builtins.head hostDatabases);
          port = mariadbPort;
          hostgroup = 0;
          max_connections = 1024;
          weight = 1000;
        }
      ];

      mysql_users =
        db.uniquePrefixes
        |> map (prefix: {
          username = prefix;
          password = getIn "${prefix}.password" secrets;
          default_hostgroup = 0;
          max_connections = 2048;
          default_schema = "information_schema";
          active = 1;
        });

      mysql_query_rules = [
        {
          rule_id = 1;
          active = 1;
          match_pattern = "^SELECT .* FOR UPDATE$";
          destination_hostgroup = 0;
          apply = 1;
        }
        {
          rule_id = 2;
          active = 1;
          match_pattern = "^SELECT";
          destination_hostgroup = 0;
          apply = 1;
        }
      ];
    };
in {
  config = mkIf (hasAttr hostName cfg.databases && cfg.databases.${hostName} != []) {
    systemd.services.proxysql = {
      description = "ProxySQL connection pooler for MariaDB";
      after = ["mysql.service"];
      requires = ["mysql.service"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "forking";
        Restart = "always";
        RestartSec = 5;

        StateDirectory = "proxysql";
        WorkingDirectory = "/var/lib/proxysql";
        LimitNOFILE = 102400;
        PIDFile = "/var/lib/proxysql/proxysql.pid";

        ExecStart = "${pkgs.proxysql}/bin/proxysql --reload --config-file=${configFile} --sqlite-runtime=true";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      };
    };

    networking.firewall.allowedTCPPorts = [port adminPort];

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistRootDir config "/var/lib/proxysql" "700")
    ];
  };
}
