{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkForce;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService resolveDatabaseHost resolveServicePort;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
  pgCfg = getAttrByNamespace config "${namespace}.services.storage.postgresql";

  isEnabled = hostHasService networkCfg.network-services hostName "asciinema";
  port = resolveServicePort networkCfg.network-services "asciinema" 4000;
in {
  imports = [
    inputs.asciinema.nixosModules.default
  ];

  config = mkIf isEnabled {
    services.asciinema = {
      enable = true;
      database.createLocally = false;

      environment = {
        BIND_ALL = true;
        PORT = port;
        URL_HOST = "asciinema.cpatino.com";
        URL_SCHEME = "https";

        SIGN_UP_DISABLED = true;
      };

      environmentFile = config.sops.secrets."environment-file/asciinema".path;
    };

    networking.firewall.allowedTCPPorts = [port];

    systemd.services.asciinema-server = mkIf (resolveDatabaseHost pgCfg.databases "asciinema" == hostName) {
      after = ["postgresql.service" "pgbouncer.service"];
      requires = ["postgresql.service" "pgbouncer.service"];
      serviceConfig = {
        RestartSec = mkForce "1s";
      };
    };

    sops.secrets."environment-file/asciinema" = {};

    ${namespace}.services.storage.impermanence.folders = [
      {
        directory = "/var/lib/asciinema";
        user = "asciinema";
        group = "asciinema";
        mode = "700";
      }
    ];
  };
}
