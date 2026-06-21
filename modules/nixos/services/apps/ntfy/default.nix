{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService resolveServicePort;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  isEnabled = hostHasService networkCfg.network-services hostName "ntfy";
  port = resolveServicePort networkCfg.network-services "ntfy" 5201;
in {
  config = mkIf isEnabled {
    services.ntfy-sh = {
      enable = true;
      settings = {
        base-url = "http://ntfy.yumeami.sh";
        upstream-base-url = "https://ntfy.sh";
        listen-http = ":${toString port}";
        behind-proxy = true;
      };
    };

    systemd.services.ntfy-sh.serviceConfig = {
      DynamicUser = mkForce false;
    };

    networking.firewall.allowedTCPPorts = [port];
  };
}
