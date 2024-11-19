{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    pm2.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable pm2";
    };
  };

  config = lib.mkIf config.pm2.enable {
    environment.systemPackages = with pkgs; [
      pm2
    ];

    systemd.services.pm2 = {
      enable = true;
      description = "pm2";
      unitConfig = {
        Type = "simple";
      };
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = "${pkgs.pm2}/bin/pm2 resurrect";
        ExecReload = "${pkgs.pm2}/bin/pm2 reload all";
        ExecStop = "${pkgs.pm2}/bin/pm2 kill";
      };
      environment = {
        HOME = config.users.users.c4patino.home;
      };
    };
  };
}
