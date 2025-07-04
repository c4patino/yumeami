{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.services.metrics.ntfy";
  cfg = getAttrByNamespace config base;

  port = 5201;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "ntfy";
  };

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
