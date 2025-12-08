{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkForce;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  inherit (config.users) users;
  base = "${namespace}.services.apps.uptime-kuma";
  cfg = getAttrByNamespace config base;

  port = 5200;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "uptime-kuma";
  };

  config = mkIf cfg.enable {
    services.uptime-kuma = {
      enable = true;
      settings = {
        HOST = "0.0.0.0";
        PORT = "${toString port}";
        NODE_EXTRA_CA_CERTS = let
          inherit (config.sops) secrets;
        in
          secrets."ssl/ca/cert".path;
      };
    };

    systemd.services.uptime-kuma.serviceConfig = {
      DynamicUser = mkForce false;
      User = users.uptime-kuma.name;
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
