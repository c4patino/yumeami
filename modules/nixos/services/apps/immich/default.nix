{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkMerge;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService mkPersistDir resolveDatabaseHost resolveDatabaseIP resolveServicePort waitForNetwork;
  inherit (config.networking) hostName;

  pgCfg = getAttrByNamespace config "${namespace}.services.storage.postgresql";
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  isEnabled = hostHasService networkCfg.network-services hostName "immich";
  port = resolveServicePort networkCfg.network-services "immich" 2283;
in {
  imports = [
    ./postgres.nix
  ];

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

      accelerationDevices = ["/dev/dri/renderD128"];
      machine-learning.enable = true;

      secretsFile = config.sops.secrets."environment-file/immich".path;

      settings.server.externalDomain = "https://photos.yumeami.sh";
    };

    systemd.services = let
      dbHost = resolveDatabaseHost pgCfg.databases "immich";
    in {
      immich-server = mkMerge [
        waitForNetwork
        (mkIf (dbHost == hostName) {
          after = ["postgresql.service" "pgbouncer.service"];
          requires = ["postgresql.service" "pgbouncer.service"];
        })
      ];
      immich-machine-learning = waitForNetwork;
    };

    sops.secrets."environment-file/immich" = {};

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistDir config "immich" "/var/lib/immich" "700")
    ];
  };
}
