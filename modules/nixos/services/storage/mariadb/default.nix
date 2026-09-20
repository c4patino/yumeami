{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) concatStringsSep getAttr hasAttr mkIf optionalString types;
  inherit (lib.${namespace}) getAttrByNamespace getIn mkOptAttrset mkOptionsWithNamespace mkPersistRootDir mkDatabaseUtils readJsonOrEmpty;
  inherit (config.networking) hostName;
  base = "${namespace}.services.storage.mariadb";
  cfg = getAttrByNamespace config base;

  port = 5651;
in {
  imports = [
    ./backup.nix
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
      };
    };

    systemd.services = {
      mysql = {
        wants = ["mariadb-setup.service"];
      };

      mariadb-setup = let
        secrets = readJsonOrEmpty "${inputs.self}/secrets/crypt/mariadb.json";
      in {
        description = "MariaDB application user setup";
        requires = ["mysql.service"];
        after = ["mysql.service"];
        partOf = ["mysql.service"];

        serviceConfig = {
          Type = "oneshot";
          User = "mysql";
          Group = "mysql";
          RemainAfterExit = true;
        };

        path = with pkgs; [
          mariadb
        ];

        script = ''
          while ! mysql -N -e "SELECT 1" >/dev/null 2>&1; do
            if ! ${pkgs.systemd}/bin/systemctl is-active --quiet mysql.service; then
              exit 1
            fi
            sleep 0.1
          done

          mysql -N <<'SQL'
          ${
            db.uniquePrefixes
            |> map (prefix:
              optionalString (getIn "${prefix}.hash" secrets != null) ''
                ALTER USER '${prefix}'@'localhost' IDENTIFIED VIA mysql_native_password USING '${getIn "${prefix}.hash" secrets}';
              '')
            |> concatStringsSep "\n"
          }
          ${
            db.auxDbs
            |> map (d: ''
              GRANT ALL PRIVILEGES ON \`${d}\`.* TO '${db.getPrefix d}'@'localhost';
            '')
            |> concatStringsSep "\n"
          }
          SQL
        '';
      };
    };

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistRootDir config "/var/lib/mysql" "700")
    ];
  });
}
