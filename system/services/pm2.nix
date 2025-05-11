{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.pm2;
  userCfg = config.users.users;
in {
  options.pm2.enable = mkEnableOption "PM2 daemon";

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
