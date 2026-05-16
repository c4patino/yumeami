{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkForce mkIf;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
  isEnabled = hostHasService networkCfg.network-services hostName "lidarr";
in {
  config = mkIf isEnabled {
    services.lidarr = {
      enable = true;
    };

    systemd.services.lidarr.serviceConfig = let
      lidarrUser = config.users.users.lidarr;
    in {
      DynamicUser = mkForce false;
      User = lidarrUser.name;
      Group = lidarrUser.group;
    };

    users = {
      users.lidarr = {
        isSystemUser = true;
        group = "lidarr";
        extraGroups = ["jellyfin" "qbittorrent"];
      };

      groups.lidarr = {};
    };

    ${namespace}.services.storage.impermanence.folders = let
      lidarrUser = config.users.users.lidarr;
    in [
      {
        directory = "/var/lib/lidarr";
        user = lidarrUser.name;
        group = lidarrUser.group;
        mode = "700";
      }
    ];
  };
}
