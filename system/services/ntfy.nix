{
  lib,
  config,
  ...
}: let
  port = 5201;
in {
  options.ntfy.enable = lib.mkEnableOption "ntfy";

  config = lib.mkIf config.ntfy.enable {
    services.ntfy-sh = {
      enable = true;
      settings = {
        base-url = "https://chibi.tail8b9fd9.ts.net:${toString port}";
        listen-http = ":${toString port}";
      };
    };

    systemd.services.ntfy-sh.serviceConfig = {
      DynamicUser = lib.mkForce false;
    };

    networking.firewall.allowedTCPPorts = [port];
  };
}
