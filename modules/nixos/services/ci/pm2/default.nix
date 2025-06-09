{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.services.ci.pm2";
  cfg = getAttrByNamespace config base;
  userCfg = config.users.users;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "pm2";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [pm2];

    systemd.services.pm2 = {
      description = "pm2";
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        User = userCfg.c4patino.name;
        Group = userCfg.c4patino.group;
        ExecStart = "${pkgs.pm2}/bin/pm2 resurrect --no-daemon";
        ExecReload = "${pkgs.pm2}/bin/pm2 reload all";
        ExecStop = "${pkgs.pm2}/bin/pm2 kill";
      };
      environment = {
        HOME = userCfg.c4patino.home;
      };
    };

    users = {
      users.pm2 = {
        isSystemUser = true;
        group = "pm2";
      };

      groups.pm2 = {};
    };
  };
}
