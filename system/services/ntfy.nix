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
        base-url = "https://chibi.tail8b9fd9.ts.net:${toString port}";
        listen-http = ":${toString port}";
      };
    };

    systemd.services.ntfy-sh.serviceConfig = {
      DynamicUser = mkForce false;
    };

    networking.firewall.allowedTCPPorts = [port];
  };
}
