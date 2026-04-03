{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) types mkIf mkOption concatStringsSep hasAttr getAttr genAttrs;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  inherit (config.networking) hostName;
  base = "${namespace}.services.storage.postgresql";
  cfg = getAttrByNamespace config base;

  port = 5601;
  pgbouncerPort = 5600;
in {
  options = with types;
    mkOptionsWithNamespace base {
      databases = mkOption {
        type = attrsOf (listOf str);
        default = {};
        description = "Map of hosts to list of databases.";
      };
    };

  config = mkIf (hasAttr hostName cfg.databases) {
    services = {
      postgresql = {
        enable = true;
        enableTCPIP = true;
        package = pkgs.postgresql_16;

        settings = {
          port = port;
        };

        authentication = let
          permissionEntries =
            cfg.databases
            |> getAttr hostName
            |> map (service: ''
              host            ${service}        ${service}      127.0.0.1/32  scram-sha-256
            '')
            |> concatStringsSep "";
        in ''
          # TYPE          DATABASE          USER            ADDRESS       METHOD
          local           all               all                           trust
          host            all               pgbouncer_auth  127.0.0.1/32  scram-sha-256
          ${permissionEntries}
        '';

        ensureDatabases = getAttr hostName cfg.databases;

        ensureUsers =
          cfg.databases
          |> getAttr hostName
          |> map (service: {
            name = service;
            ensureDBOwnership = true;
          });
      };

      postgresqlBackup = {
        enable = true;
        databases =
          cfg.databases
          |> getAttr hostName;
        compression = "zstd";
        compressionLevel = 4;
        startAt = "*-*-* 23:00:00";
      };

      pgbouncer = {
        enable = true;
        settings = {
          pgbouncer = {
            listen_addr = "0.0.0.0";
            listen_port = pgbouncerPort;

            default_pool_size = 10;
            max_client_conn = 500;
            pool_mode = "transaction";

            stats_users = "pgbouncer_auth";

            auth_file = config.sops.secrets."postgresql/pgbouncer/auth_file".path;
            auth_type = "scram-sha-256";
            auth_user = "pgbouncer_auth";
            auth_dbname = "postgres";
            auth_query = "SELECT uname, phash FROM pgbouncer_lookup($1)";

            ignore_startup_parameters =
              ["extra_float_digits"]
              |> concatStringsSep "\n";
          };
          databases =
            cfg.databases
            |> getAttr hostName
            |> (dbs: dbs ++ ["postgres"])
            |> (dbs: genAttrs dbs (db: "host=127.0.0.1 port=${toString port} dbname=${db}"));
        };
      };
    };

    sops.secrets = let
      inherit (config.users.users) pgbouncer;
    in {
      "postgresql/pgbouncer/auth_file" = {
        owner = pgbouncer.name;
        group = pgbouncer.group;
      };
    };

    ${namespace}.services.storage.impermanence.folders = [
      "/var/lib/postgresql"
      "/var/lib/pgbouncer"
    ];
  };
}
