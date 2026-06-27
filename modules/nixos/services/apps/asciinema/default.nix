{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkForce;
  inherit (lib.${namespace}) getAttrByNamespace getIn hostHasService readJsonOrEmpty resolveDatabaseHost resolveDatabaseIP resolveServicePort;
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

      environmentFile = let
        secrets = readJsonOrEmpty "${inputs.self}/secrets/crypt/secrets.json";
        ip = resolveDatabaseIP networkCfg.devices pgCfg.databases "asciinema";
        password = getIn "postgresql.asciinema.password" secrets;
      in
        pkgs.writeText "asciinema.env" ''
          DATABASE_URL=ecto://asciinema:${password}@${ip}:5600/asciinema
        '';
    };

    networking.firewall.allowedTCPPorts = [port];

    systemd.services.asciinema-server = mkIf (resolveDatabaseHost pgCfg.databases "asciinema" == hostName) {
      after = ["postgresql.service" "pgbouncer.service"];
      requires = ["postgresql.service" "pgbouncer.service"];
      serviceConfig = {
        RestartSec = mkForce "1s";
      };
    };

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
