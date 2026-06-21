{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkForce mkIf;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService resolveServicePort;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  isEnabled = hostHasService networkCfg.network-services hostName "radarr";
  port = resolveServicePort networkCfg.network-services "radarr" 7878;
in {
  config = mkIf isEnabled {
    services.radarr = {
      enable = true;
      settings.server.port = port;
    };

    systemd.services.radarr.serviceConfig = let
      radarrUser = config.users.users.radarr;
    in {
      DynamicUser = mkForce false;
      User = radarrUser.name;
      Group = radarrUser.group;
      UMask = mkForce "0002";
    };

    users = {
      users.radarr = {
        isSystemUser = true;
        group = "radarr";
        extraGroups = ["jellyfin" "qbittorrent"];
      };

      groups.radarr = {};
    };

    ${namespace}.services.storage.impermanence.folders = let
      radarrUser = config.users.users.radarr;
    in [
      {
        directory = "/var/lib/radarr";
        user = radarrUser.name;
        group = radarrUser.group;
        mode = "700";
      }
    ];
  };
}
