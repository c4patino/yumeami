{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace hostHasService flattenHostServices getServicePort;
  inherit (config.networking) hostName;

  base = "${namespace}.services.networking.miasma";
  cfg = getAttrByNamespace config base;
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
  networkServices = flattenHostServices networkCfg.network-services;

  isEnabled = hostHasService networkCfg.network-services hostName "miasma";
  port = getServicePort networkServices "miasma" 9999;
in {
  options = with types;
    mkOptionsWithNamespace base {
      host = mkOption {
        type = str;
        default = "0.0.0.0";
        description = "Host address to bind to";
      };
      linkPrefix = mkOption {
        type = str;
        default = "/miasma";
        description = "prefix for self-directing links";
      };
    };

  config = mkIf isEnabled {
    systemd.services.miasma = {
      description = "Trap AI web scrapers in an endless poison pit";
      wantedBy = ["multi-user.target"];
      serviceConfig = let
        miasmaUser = config.users.users.miasma;
      in {
        Type = "simple";
        Restart = "always";
        RestartSec = 1;

        User = miasmaUser.name;
        Group = miasmaUser.group;

        StateDirectory = "miasma";
        ReadWritePaths = "/var/lib/miasma";

        ExecStart = "${pkgs.miasma}/bin/miasma --host ${cfg.host} --port ${toString port} --link-prefix ${cfg.linkPrefix}";
      };
    };

    users = {
      users.miasma = {
        isSystemUser = true;
        group = "miasma";
      };
      groups.miasma = {};
    };
  };
}
