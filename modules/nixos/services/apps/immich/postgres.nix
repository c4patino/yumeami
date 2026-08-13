{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) concatStringsSep mkAfter mkIf;
  inherit (lib.${namespace}) getAttrByNamespace;
  inherit (config.networking) hostName;

  pgCfg = getAttrByNamespace config "${namespace}.services.storage.postgresql";

  hasImmichDb = builtins.elem "immich" (pgCfg.databases.${hostName} or []);
in {
  config = mkIf hasImmichDb {
    services.postgresql = {
      settings = {
        shared_preload_libraries = ["vchord.so"];
        search_path = "\"$user\", public, vectors";
      };
      extensions = ps:
        with ps; [
          pgvector
          vectorchord
        ];
    };

    systemd.services.postgresql-setup.postStart = mkAfter ''
      ${
        ["unaccent" "uuid-ossp" "cube" "earthdistance" "pg_trgm" "vector" "vchord"]
        |> map (ext: "psql -d immich -v ON_ERROR_STOP=1 -c 'CREATE EXTENSION IF NOT EXISTS \"${ext}\";'")
        |> concatStringsSep "\n"
      }
      psql -d immich -v ON_ERROR_STOP=1 -c 'ALTER SCHEMA public OWNER TO immich;'
    '';
  };
}
