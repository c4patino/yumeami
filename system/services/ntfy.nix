{
  lib,
  config,
  ...
}: let
  port = 5201;
  appService = {
    name = "ntfy";
    port = port;
  };
in {
  options.ntfy.enable = lib.mkEnableOption "ntfy";

  config = lib.mkIf config.ntfy.enable {
    services.ntfy-sh = {
      enable = true;
      settings = {
        base-url = "https://chibi.tail8b9fd9.ts.net:${port}";
        listen-http = ":${port}";
      };
    };

    systemd.services.ntfy-sh.serviceConfig = {
      DynamicUser = lib.mkForce false;
    };

    networking.firewall.allowedTCPPorts = [port];

    httpd.services = [appService];
  };
}
