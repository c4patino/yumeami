{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) concatStringsSep getAttr hasAttr hasInfix head mkIf optionalString splitString types unique;
  inherit (lib.${namespace}) getAttrByNamespace getIn mkOptAttrset mkOptionsWithNamespace mkPersistRootDir readJsonOrEmpty;
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

  config = mkIf (hasAttr hostName cfg.databases) (let
    hostDatabases = getAttr hostName cfg.databases;
    secrets = readJsonOrEmpty "${inputs.self}/secrets/crypt/mariadb.json";

    getPrefix = db: head (splitString "-" db);
    uniquePrefixes = hostDatabases |> map getPrefix |> unique;
    isMainDb = db: !(hasInfix "-" db);
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
          uniquePrefixes
          |> map (prefix: {
            name = prefix;
            ensurePermissions = {
              "${prefix}.*" = "ALL PRIVILEGES";
            };
          });

        initialScript = let
          userInit =
            uniquePrefixes
            |> map (prefix:
              optionalString (getIn "${prefix}.password" secrets != null) ''
                SET PASSWORD FOR '${prefix}'@'localhost' = PASSWORD('${getIn "${prefix}.password" secrets}');
              '')
            |> concatStringsSep "\n";
        in
          pkgs.writeText "mysql-init.userInit" ''
            ${userInit}
          '';
      };
    };

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistRootDir config "/var/lib/mysql" "700")
    ];
  });
}
