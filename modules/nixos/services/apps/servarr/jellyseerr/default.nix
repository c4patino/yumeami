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
  isEnabled = hostHasService networkCfg.network-services hostName "jellyseerr";
in {
  config = mkIf isEnabled {
    services.jellyseerr = {
      enable = true;
      openFirewall = true;
    };

    systemd.services.jellyseerr.serviceConfig = let
      jellyseerrUser = config.users.users.jellyseerr;
    in {
      DynamicUser = mkForce false;
      User = jellyseerrUser.name;
      Group = jellyseerrUser.group;
    };

    users = {
      users.jellyseerr = {
        isSystemUser = true;
        group = "jellyseerr";
      };

      groups.jellyseerr = {};
    };

    ${namespace}.services.storage.impermanence.folders = let
      jellyseerrUser = config.users.users.jellyseerr;
    in [
      {
        directory = "/var/lib/jellyseerr";
        user = jellyseerrUser.name;
        group = jellyseerrUser.group;
        mode = "700";
      }
    ];
  };
}
