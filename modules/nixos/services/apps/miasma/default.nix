{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf types;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace hostHasService resolveServicePort mkOpt;
  inherit (config.networking) hostName;

  base = "${namespace}.services.apps.miasma";
  cfg = getAttrByNamespace config base;
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  isEnabled = hostHasService networkCfg.network-services hostName "miasma";
  port = resolveServicePort networkCfg.network-services "miasma" 9999;
in {
  options = with types;
    mkOptionsWithNamespace base {
      host = mkOpt str "0.0.0.0" "Host address to bind to";
      linkPrefix = mkOpt str "/miasma" "prefix for self-directing links";
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
