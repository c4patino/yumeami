{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService mkOpt mkOptionsWithNamespace resolveServicePort;
  inherit (config.networking) hostName;

  base = "${namespace}.services.apps.miasma";
  cfg = getAttrByNamespace config base;
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  isEnabled = hostHasService networkCfg.registry hostName "miasma";
  port = resolveServicePort networkCfg.registry "miasma" 9999;
in {
  options = with types;
    mkOptionsWithNamespace base {
      host = mkOpt str "0.0.0.0" "Host address to bind to";
      linkPrefix = mkOpt str "/miasma" "prefix for self-directing links";
      settings = mkOption {
        type = attrs;
        default = {};
        internal = true;
        description = "Miasma configuration assembled by module options.";
      };
    };

  config = mkIf isEnabled {
    ${namespace}.services.apps.miasma.settings = {
      server = {
        host = cfg.host;
        port = port;
      };

      link_prefix = cfg.linkPrefix;
      max_in_flight = 50;
      force_gzip = true;
    };

    systemd.services.miasma = {
      description = "Trap AI web scrapers in an endless poison pit";
      wantedBy = ["multi-user.target"];
      serviceConfig = let
        inherit (config.users.users) miasma;

        configFile = (pkgs.formats.yaml {}).generate "miasma.yaml" cfg.settings;
      in {
        Type = "simple";
        Restart = "always";
        RestartSec = 1;

        User = miasma.name;
        Group = miasma.group;

        StateDirectory = "miasma";
        ReadWritePaths = "/var/lib/miasma";

        ExecStart = "${pkgs.miasma}/bin/miasma --config-file ${configFile}";
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
