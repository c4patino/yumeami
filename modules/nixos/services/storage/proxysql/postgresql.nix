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
  base = "${namespace}.services.storage.postgresql";
  cfg = getAttrByNamespace config base;

  port = 5600;
  postgresqlPort = 5601;
in {
  config = mkIf (hasAttr hostName cfg.databases && cfg.databases.${hostName} != []) (let
    databases = getAttr hostName cfg.databases;
    db = mkDatabaseUtils databases;
    secrets = readJsonOrEmpty "${inputs.self}/secrets/crypt/postgresql.json";
  in {
    ${namespace}.services.storage.proxysql = {
      settings = {
        pgsql_variables.interfaces = "0.0.0.0:${toString port}";

        pgsql_servers = [
          {
            address = "127.0.0.1";
            port = postgresqlPort;
            hostgroup = 0;
          }
        ];

        pgsql_users =
          db.uniquePrefixes
          |> map (prefix: {
            username = prefix;
            password = getIn "${prefix}.password" secrets;
          });
      };
    };

    systemd.services.proxysql = {
      after = [
        "postgresql.service"
        "postgresql-setup.service"
      ];
      requires = [
        "postgresql.service"
        "postgresql-setup.service"
      ];
    };

    networking.firewall.allowedTCPPorts = [port];
  });
}
