{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkForce;
  cfg = config.uptime-kuma;
  userCfg = config.users.users;

  port = 5200;
in {
  options.uptime-kuma.enable = mkEnableOption "uptime-kuma";

  config = mkIf cfg.enable {
    services.uptime-kuma = {
      enable = true;
      settings = {
        HOST = "0.0.0.0";
        PORT = "${toString port}";
      };
    };

    systemd.services.uptime-kuma.serviceConfig = {
      DynamicUser = mkForce false;
      User = userCfg.uptime-kuma.name;
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
