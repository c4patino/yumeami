{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf concatStringsSep hasAttr getAttr genAttrs;
  inherit (lib.${namespace}) getAttrByNamespace readJsonOrEmpty getIn mkPersistDir;
  inherit (config.networking) hostName;
  base = "${namespace}.services.storage.postgresql";
  cfg = getAttrByNamespace config base;

  port = 5601;
  pgbouncerPort = 5600;
in {
  config = mkIf (hasAttr hostName cfg.databases) (let
    hostDatabases = getAttr hostName cfg.databases;
  in {
    services = {
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

      postgresql.ensureUsers = [
        {
          name = "pgbouncer_auth";
          ensureClauses = let
            secrets = readJsonOrEmpty "${inputs.self}/secrets/crypt/postgresql.json";
            hash = getIn "pgbouncer_auth.hash" secrets;
          in {
            login = true;
            password = hash;
          };
        }
      ];
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
      (mkPersistDir config "pgbouncer" "/var/lib/pgbouncer" "700")
    ];
  });
}
