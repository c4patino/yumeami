{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
} @ args: let
  inherit (lib) types mkIf mkMerge concatStringsSep hasAttr getAttr filter optionalString head splitString;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace readJsonOrEmpty getIn mkOptAttrset;
  inherit (config.networking) hostName;
  base = "${namespace}.services.storage.postgresql";
  cfg = getAttrByNamespace config base;

  port = 5601;
in {
  imports = [
    (import ./pgbouncer.nix args)
  ];

  options = with types;
    mkOptionsWithNamespace base {
      databases = mkOptAttrset (listOf str) {} "Map of hosts to list of databases.";
    };

  config = mkIf (hasAttr hostName cfg.databases) (let
    hostDatabases = getAttr hostName cfg.databases;
    mainServices = filter (db: !(lib.hasSuffix "-log" db)) hostDatabases;
    auxDbs = filter (lib.hasSuffix "-log") hostDatabases;
  in {
    services = {
      postgresql = {
        enable = true;
        enableTCPIP = true;
        package = pkgs.postgresql_17;

        settings = mkMerge [
          {
            port = port;
          }
          (mkIf (builtins.elem "immich" mainServices) {
            shared_preload_libraries = ["vchord.so"];
            search_path = "\"$user\", public, vectors";
          })
        ];

        extensions = mkIf (builtins.elem "immich" mainServices) (ps:
          with ps; [
            pgvector
            vectorchord
          ]);

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
          mainServices
          |> map (service: {
            name = service;
            ensureDBOwnership = true;
            ensureClauses = let
              secrets = readJsonOrEmpty "${inputs.self}/secrets/crypt/postgresql.json";
            in {
              login = true;
              password = getIn "${service}.hash" secrets;
            };
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
    };

    ${namespace}.services.storage.impermanence.folders = [
      "/var/lib/postgresql"
    ];

    systemd.services.postgresql-setup.postStart = ''
      if [ -f "${config.services.postgresql.dataDir}/standby.signal" ]; then
        echo "Skipping setup because PostgreSQL is in standby mode"
        exit 0
      fi

      psql -v ON_ERROR_STOP=1 -d postgres <<'SQL'
        CREATE OR REPLACE FUNCTION public.pgbouncer_lookup(IN i_username text, OUT uname text, OUT phash text)
        RETURNS record
        LANGUAGE sql
        SECURITY DEFINER
        AS $$
          SELECT usename, passwd
          FROM pg_catalog.pg_shadow
          WHERE usename = i_username;
        $$;

        REVOKE ALL ON FUNCTION public.pgbouncer_lookup(text) FROM PUBLIC;
        ALTER FUNCTION public.pgbouncer_lookup(text) OWNER TO postgres;
        ALTER FUNCTION public.pgbouncer_lookup(text) SET search_path = pg_catalog;
        GRANT EXECUTE ON FUNCTION public.pgbouncer_lookup(text) TO pgbouncer_auth;

      ${
        auxDbs
        |> map (db: let
          user = head (splitString "-" db);
        in ''
          GRANT ALL PRIVILEGES ON DATABASE "${db}" TO "${user}";
          ALTER DATABASE "${db}" OWNER TO "${user}";
        '')
        |> concatStringsSep "\n"
      }
      SQL

      ${
        optionalString (builtins.elem "immich" mainServices) ''
          ${
            ["unaccent" "uuid-ossp" "cube" "earthdistance" "pg_trgm" "vector" "vchord"]
            |> map (ext: "psql -d immich -v ON_ERROR_STOP=1 -c 'CREATE EXTENSION IF NOT EXISTS \"${ext}\";'")
            |> concatStringsSep "\n"
          }
          psql -d immich -v ON_ERROR_STOP=1 -c 'ALTER SCHEMA public OWNER TO immich;'
        ''
      }
    '';
  });
}
