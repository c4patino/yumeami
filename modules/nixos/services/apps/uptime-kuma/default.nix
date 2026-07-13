{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkForce;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService resolveServicePort mkPersistDir;
  inherit (config.users) users;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  isEnabled = hostHasService networkCfg.network-services hostName "monitor";
  port = resolveServicePort networkCfg.network-services "monitor" 5200;
in {
  config = mkIf isEnabled {
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

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistDir config "uptime-kuma" "/var/lib/uptime-kuma" "700")
    ];
  };
}
