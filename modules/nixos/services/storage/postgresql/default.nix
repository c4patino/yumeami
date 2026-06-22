{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) types mkIf concatStringsSep hasAttr getAttr genAttrs filter;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace readJsonOrEmpty getIn mkOpt mkOptAttrset mkListOpt;
  inherit (config.networking) hostName;
  base = "${namespace}.services.storage.postgresql";
  cfg = getAttrByNamespace config base;

  port = 5601;
  pgbouncerPort = 5600;
in {
  options = with types;
    mkOptionsWithNamespace base {
      databases = mkOptAttrset (listOf str) {} "Map of hosts to list of databases.";
    };

  config = mkIf (hasAttr hostName cfg.databases) (let
    hostDatabases = getAttr hostName cfg.databases;
    mainServices = filter (db: !(lib.hasSuffix "-log" db)) hostDatabases;
    logDatabases = filter (lib.hasSuffix "-log") hostDatabases;
  in {
    services = {
      postgresql = {
        enable = true;
        enableTCPIP = true;
        package = pkgs.postgresql_17;

        settings = {
          port = port;
        };

        authentication = let
          permissionEntries =
            hostDatabases
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

        ensureDatabases = hostDatabases;

        ensureUsers =
          [
            {
              name = "pgbouncer_auth";
              ensureClauses = let
                secrets = readJsonOrEmpty "${inputs.self}/secrets/crypt/secrets.json";
                hash = getIn "postgresql.pgbouncer_auth.hash" secrets;
              in {
                login = true;
                password = hash;
              };
            }
          ]
          ++ (mainServices
            |> map (service: {
              name = service;
              ensureDBOwnership = true;
              ensureClauses = let
                secrets = readJsonOrEmpty "${inputs.self}/secrets/crypt/secrets.json";
                hash = getIn "postgresql.${service}.hash" secrets;
              in {
                login = true;
                password = hash;
              };
            }));

        initialScript = pkgs.writeText "init-sql-script" ''
          CREATE OR REPLACE FUNCTION pgbouncer_lookup(IN i_username text, OUT uname text, OUT phash text)
          RETURNS record
          LANGUAGE sql
          SECURITY DEFINER
          AS $$
            SELECT usename, passwd
            FROM pg_shadow
            WHERE usename = i_username;
          $$;

          REVOKE ALL ON FUNCTION pgbouncer_lookup(text) FROM PUBLIC;
          ALTER FUNCTION pgbouncer_lookup(text) OWNER TO postgres;
          ALTER FUNCTION pgbouncer_lookup(text) SET search_path = pg_catalog;
          GRANT EXECUTE ON FUNCTION pgbouncer_lookup(text) TO pgbouncer_auth;

          ${concatStringsSep "\n" (map (logDb: let
              mainUser = lib.removeSuffix "-log" logDb;
            in ''
              GRANT ALL PRIVILEGES ON DATABASE "${logDb}" TO "${mainUser}";
              ALTER DATABASE "${logDb}" OWNER TO "${mainUser}";
            '')
            logDatabases)}
        '';
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
            hostDatabases
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
  });
}
