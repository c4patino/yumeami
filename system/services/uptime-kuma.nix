{
  lib,
  config,
  ...
}: let
  port = 5200;
in {
  options.uptime-kuma.enable = lib.mkEnableOption "uptime-kuma";

  config = lib.mkIf config.uptime-kuma.enable {
    services.uptime-kuma = {
      enable = true;
      settings = {
        HOST = "0.0.0.0";
        PORT = "${toString port}";
      };
    };

    systemd.services.uptime-kuma.serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = config.users.users.uptime-kuma.name;
    };

    users = {
      users.uptime-kuma = {
        isSystemUser = true;
        group = "uptime-kuma";
      };

      groups.uptime-kuma = {};
    };

    networking.firewall.allowedTCPPorts = [port];
  };
}
