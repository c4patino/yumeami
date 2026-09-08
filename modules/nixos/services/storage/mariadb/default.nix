{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) concatStringsSep filter getAttr hasAttr mkIf optionalString types;
  inherit (lib.${namespace}) getAttrByNamespace getIn mkOptAttrset mkOptionsWithNamespace mkPersistRootDir mkDatabaseUtils readJsonOrEmpty;
  inherit (config.networking) hostName;
  base = "${namespace}.services.storage.mariadb";
  cfg = getAttrByNamespace config base;

  port = 5651;
in {
  imports = [
    ./backup.nix
    ./proxysql.nix
  ];

  options = with types;
    mkOptionsWithNamespace base {
      databases = mkOptAttrset (listOf str) {} "Map of hosts to list of databases.";
    };

  config = mkIf (hasAttr hostName cfg.databases && cfg.databases.${hostName} != []) (let
    hostDatabases = getAttr hostName cfg.databases;
    db = mkDatabaseUtils hostDatabases;
  in {
    services = {
      mysql = {
        enable = true;
        package = pkgs.mariadb;

        settings = {
          mysqld = {
            port = port;
            bind = "127.0.0.1";
            skip-symbolic-links = true;
          };
        };

        ensureDatabases = hostDatabases;

        ensureUsers =
          db.uniquePrefixes
          |> map (prefix: {
            name = prefix;
            ensurePermissions = {
              "${prefix}.*" = "ALL PRIVILEGES";
            };
          });

        initialScript = let
          secrets = readJsonOrEmpty "${inputs.self}/secrets/crypt/mariadb.json";

          userInit =
            db.uniquePrefixes
            |> map (prefix:
              optionalString (getIn "${prefix}.password" secrets != null) ''
                SET PASSWORD FOR '${prefix}'@'localhost' = PASSWORD('${getIn "${prefix}.password" secrets}');
              '')
            |> concatStringsSep "\n";

          grantsInit =
            db.uniquePrefixes
            |> map (
              prefix:
                (db.databasesForPrefix prefix ++ [prefix])
                |> map (d: ''
                  GRANT ALL PRIVILEGES ON \`${d}\`.* TO '${prefix}'@'localhost';
                '')
                |> concatStringsSep "\n"
            )
            |> concatStringsSep "\n";
        in
          pkgs.writeText "mysql-init.userInit" ''
            ${userInit}
            ${grantsInit}
          '';
      };
    };

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistRootDir config "/var/lib/mysql" "700")
    ];
  });
}
