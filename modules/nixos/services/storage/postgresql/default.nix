{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
} @ args: let
  inherit (lib) types mkIf concatStringsSep hasAttr getAttr filter;
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

        ${concatStringsSep "\n" (map (logDb: let
          mainUser = lib.removeSuffix "-log" logDb;
        in ''
          GRANT ALL PRIVILEGES ON DATABASE "${logDb}" TO "${mainUser}";
          ALTER DATABASE "${logDb}" OWNER TO "${mainUser}";
        '')
        logDatabases)}
      SQL
    '';
  });
}
