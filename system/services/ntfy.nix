{
  lib,
  config,
  ...
}: {
  options.ntfy.enable = lib.mkEnableOption "ntfy";

  config = lib.mkIf config.ntfy.enable {
    services.ntfy-sh = {
      enable = true;
      settings = {
        base-url = "https://chibi.tail8b9fd9.ts.net:50000";
        listen-http = ":50000";
      };
    };

    networking.firewall.allowedTCPPorts = [50000];
  };
}
