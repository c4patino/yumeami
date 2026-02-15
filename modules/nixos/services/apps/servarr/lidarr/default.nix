{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkForce mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.services.apps.servarr.lidarr";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "lidarr";
  };

  config = mkIf cfg.enable {
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
