{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace resolveDatabaseHost resolveDatabaseIP hostHasService resolveServicePort;
  inherit (config.networking) hostName;

  pgCfg = getAttrByNamespace config "${namespace}.services.storage.postgresql";
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  isEnabled = hostHasService networkCfg.network-services hostName "immich";
  port = resolveServicePort networkCfg.network-services "immich" 2283;
in {
  config = mkIf isEnabled {
    services.immich = {
      enable = true;
      host = "0.0.0.0";
      port = port;
      openFirewall = true;

      database = {
        enable = false;
        host = resolveDatabaseIP networkCfg.devices pgCfg.databases "immich";
        port = 5600;
        name = "immich";
        user = "immich";
      };

      secretsFile = config.sops.secrets."environment-file/immich".path;

      settings.server.externalDomain = "https://photos.yumeami.sh";
    };

    systemd.services.immich-server = let
      dbHost = resolveDatabaseHost pgCfg.databases "immich";
    in
      mkIf (dbHost == hostName) {
        after = ["postgresql.service" "pgbouncer.service"];
        requires = ["postgresql.service" "pgbouncer.service"];
      };

    sops.secrets."environment-file/immich" = {};

    ${namespace}.services.storage.impermanence.folders = let
      immichUser = config.users.users.immichUser;
    in [
      {
        directory = "/var/lib/immich";
        user = immichUser.name;
        group = immichUser.group;
        mode = "700";
      }
    ];
  };
}
