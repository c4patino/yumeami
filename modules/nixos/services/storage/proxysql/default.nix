{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) hasAttr mkIf mkOption types;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace mkPersistRootDir;
  base = "${namespace}.services.storage.proxysql";
  cfg = getAttrByNamespace config base;
  mariadbCfg = getAttrByNamespace config "${namespace}.services.storage.mariadb";
  postgresqlCfg = getAttrByNamespace config "${namespace}.services.storage.postgresql";

  inherit (config.networking) hostName;
  configFile = (pkgs.formats.libconfig {}).generate "proxysql.cnf" cfg.settings;
in {
  imports = [
    ./mariadb.nix
    # ./postgresql.nix
  ];

  options = with types;
    mkOptionsWithNamespace base {
      settings = mkOption {
        type = attrs;
        default = {};
        internal = true;
        description = "ProxySQL configuration assembled by storage protocol modules.";
      };
    };

  config = let
    hasLocalDatabases = databases: hasAttr hostName databases && databases.${hostName} != [];
    isEnabled = hasLocalDatabases mariadbCfg.databases || hasLocalDatabases postgresqlCfg.databases;
  in
    mkIf isEnabled {
      ${namespace} = {
        services.storage.proxysql.settings = {
          datadir = "/var/lib/proxysql";

          admin_variables = {
            admin_credentials = "admin:admin";
            mysql_ifaces = "127.0.0.1:5652";
          };
        };

        services.storage.impermanence.folders = [
          (mkPersistRootDir config "/var/lib/proxysql" "700")
        ];
      };

      systemd.services.proxysql = {
        description = "ProxySQL database connection pooler";
        wantedBy = ["multi-user.target"];

        serviceConfig = {
          Type = "forking";
          Restart = "always";
          RestartSec = 5;

          StateDirectory = "proxysql";
          WorkingDirectory = "/var/lib/proxysql";
          LimitNOFILE = 102400;
          PIDFile = "/var/lib/proxysql/proxysql.pid";

          ExecStart = "${pkgs.proxysql}/bin/proxysql --reload --config ${configFile} --sqlite-runtime=true";
          ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        };
      };
    };
}
