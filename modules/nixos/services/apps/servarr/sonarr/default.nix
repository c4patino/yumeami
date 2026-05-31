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
  isEnabled = hostHasService networkCfg.network-services hostName "sonarr";
in {
  config = mkIf isEnabled {
    services.sonarr = {
      enable = true;
    };

    systemd.services.sonarr.serviceConfig = let
      sonarrUser = config.users.users.sonarr;
    in {
      DynamicUser = mkForce false;
      User = sonarrUser.name;
      Group = sonarrUser.group;
      UMask = mkForce "0002";
    };

    users = {
      users.sonarr = {
        isSystemUser = true;
        group = "sonarr";
        extraGroups = ["jellyfin" "qbittorrent"];
      };

      groups.sonarr = {};
    };

    ${namespace}.services.storage.impermanence.folders = let
      sonarrUser = config.users.users.sonarr;
    in [
      {
        directory = "/var/lib/sonarr";
        user = sonarrUser.name;
        group = sonarrUser.group;
        mode = "700";
      }
    ];
  };
}
