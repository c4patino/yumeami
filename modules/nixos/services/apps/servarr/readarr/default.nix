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
  isEnabled = hostHasService networkCfg.network-services hostName "readarr";
in {
  config = mkIf isEnabled {
    services.readarr = {
      enable = true;
    };

    systemd.services.readarr.serviceConfig = let
      readarrUser = config.users.users.readarr;
    in {
      DynamicUser = mkForce false;
      User = readarrUser.name;
      Group = readarrUser.group;
    };

    users = {
      users.readarr = {
        isSystemUser = true;
        group = "readarr";
        extraGroups = ["jellyfin" "qbittorrent"];
      };

      groups.readarr = {};
    };

    ${namespace}.services.storage.impermanence.folders = let
      readarrUser = config.users.users.readarr;
    in [
      {
        directory = "/var/lib/readarr";
        user = readarrUser.name;
        group = readarrUser.group;
        mode = "700";
      }
    ];
  };
}
