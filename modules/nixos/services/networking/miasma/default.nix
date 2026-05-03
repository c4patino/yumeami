{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;

  base = "${namespace}.services.networking.miasma";
  cfg = getAttrByNamespace config base;

  port = 9999;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "miasma";
      host = mkOption {
        type = str;
        default = "localhost";
        description = "Host address to bind to";
      };
      linkPrefix = mkOption {
        type = str;
        default = "/miasma";
        description = "prefix for self-directing links";
      };
    };

  config = mkIf cfg.enable {
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

        ExecStart = "${pkgs.miasma}/bin/miasma -p ${toString port} --link-prefix ${cfg.linkPrefix}";
      };
    };

    users = {
      users.miasma = {
        isSystemUser = true;
        group = "miasma";
      };
      groups.miasma = {};
    };

    ${namespace}.services.storage.impermanence.folders = let
      miasmaUser = config.users.users.miasma;
    in [
      {
        directory = "/var/lib/miasma";
        user = miasmaUser.name;
        group = miasmaUser.group;
        mode = "700";
      }
    ];
  };
}
