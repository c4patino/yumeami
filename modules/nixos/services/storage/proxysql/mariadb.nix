{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) getAttr hasAttr mkIf;
  inherit (lib.${namespace}) getAttrByNamespace getIn mkDatabaseUtils readJsonOrEmpty;
  inherit (config.networking) hostName;
  base = "${namespace}.services.storage.mariadb";
  cfg = getAttrByNamespace config base;

  port = 5650;
  mariadbPort = 5651;
in {
  config = mkIf (hasAttr hostName cfg.databases && cfg.databases.${hostName} != []) (let
    databases = getAttr hostName cfg.databases;
    db = mkDatabaseUtils databases;
    secrets = readJsonOrEmpty "${inputs.self}/secrets/crypt/mariadb.json";
  in {
    ${namespace}.services.storage.proxysql = {
      settings = {
        mysql_variables.interfaces = "0.0.0.0:${toString port}";

        mysql_servers = [
          {
            address = "127.0.0.1";
            port = mariadbPort;
            hostgroup = 0;
          }
        ];

        mysql_users =
          db.uniquePrefixes
          |> map (prefix: {
            username = prefix;
            password = getIn "${prefix}.password" secrets;
          });
      };
    };

    systemd.services.proxysql = {
      after = [
        "mysql.service"
        "mariadb-setup.service"
      ];
      requires = [
        "mysql.service"
        "mariadb-setup.service"
      ];
    };

    networking.firewall.allowedTCPPorts = [port];
  });
}
