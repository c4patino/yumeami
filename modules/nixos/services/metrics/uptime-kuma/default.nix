{
  config,
  inputs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.services.metrics.uptime-kuma";
  cfg = getAttrByNamespace config base;

  port = 5200;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "uptime-kuma";
    };

  config = mkIf cfg.enable {
    services.uptime-kuma = {
      enable = true;
      settings = {
        HOST = "0.0.0.0";
        PORT = "${toString port}";
        NODE_EXTRA_CA_CERTS = "${inputs.self}/secrets/crypt/ssl/ca.crt";
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

    ${namespace}.services.storage.impermanence.folders = ["/var/lib/uptime-kuma"];
  };
}
