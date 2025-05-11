{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkForce;
  cfg = config.ntfy;

  port = 5201;
in {
  options.ntfy.enable = mkEnableOption "ntfy";

  config = mkIf cfg.enable {
    services.ntfy-sh = {
      enable = true;
      settings = {
        base-url = "http://ntfy.yumeami.sh:${toString port}";
        listen-http = ":${toString port}";
      };
    };

    systemd.services.ntfy-sh.serviceConfig = {
      DynamicUser = mkForce false;
    };

    networking.firewall.allowedTCPPorts = [port];
  };
}
