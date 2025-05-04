{
  self,
  pkgs,
  lib,
  config,
  ...
}: let
  port = 5100;
in {
  options.rustypaste.enable = lib.mkEnableOption "rustypaste daemon";

  config = lib.mkIf config.rustypaste.enable {
    environment.systemPackages = with pkgs; [rustypaste-cli];

    systemd.services.rustypaste = {
      description = "rustypaste";

      wantedBy = ["multi-user.target"];

      environment = {
        CONFIG = "/etc/rustypaste/rustypaste.toml";
      };

      serviceConfig = {
        User = config.users.users.rustypaste.name;

        WorkingDirectory = "/var/lib/rustypaste";
        StateDirectory = "rustypaste";

        ExecStart = "${pkgs.rustypaste}/bin/rustypaste";
        Restart = "always";
        RestartSec = 30;
      };
    };

    users = {
      users.rustypaste = {
        isSystemUser = true;
        group = "rustypaste";
      };

      groups.rustypaste = {};
    };

    environment.etc."rustypaste/rustypaste.toml" = {
      source = "${self}/secrets/crypt/rustypaste/server.toml";
      mode = "0755";
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/rustypaste 2750 rustypaste rustypaste -"
    ];

    networking.firewall.allowedTCPPorts = [port];
  };
}
