{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) concatStringsSep filter getAttr hasAttr mkIf splitString types;
  inherit (lib.${namespace}) getAttrByNamespace getIn mkOptAttrset mkOptionsWithNamespace mkPersistDir mkDatabaseUtils readJsonOrEmpty;
  inherit (config.networking) hostName;
  base = "${namespace}.services.storage.postgresql";
  cfg = getAttrByNamespace config base;

  port = 5601;
in {
  imports = [
    ./backup.nix
    ./pgbouncer.nix
  ];

  options = with types;
    mkOptionsWithNamespace base {
      databases = mkOptAttrset (listOf str) {} "Map of hosts to list of databases.";
    };

  config = mkIf (hasAttr hostName cfg.databases) (let
    hostDatabases = getAttr hostName cfg.databases;
    db = mkDatabaseUtils hostDatabases;
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
          db.uniquePrefixes
          |> map (prefix: {
            name = prefix;
            ensureDBOwnership = true;
            ensureClauses = let
              secrets = readJsonOrEmpty "${inputs.self}/secrets/crypt/postgresql.json";
            in {
              login = true;
              password = getIn "${prefix}.hash" secrets;
            };
          });
      };
    };

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
        db.auxDbs
        |> map (d: let
          user = db.getPrefix d;
        in ''
          GRANT ALL PRIVILEGES ON DATABASE "${d}" TO "${user}";
          ALTER DATABASE "${d}" OWNER TO "${user}";
        '')
        |> concatStringsSep "\n"
      }
      SQL
    '';

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistDir config "postgres" "/var/lib/postgresql" "700")
    ];
  });
}
