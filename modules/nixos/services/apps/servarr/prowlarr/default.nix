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
  isEnabled = hostHasService networkCfg.network-services hostName "prowlarr";
in {
  config = mkIf isEnabled {
    services.prowlarr = {
      enable = true;
    };

    systemd.services.prowlarr.serviceConfig = let
      prowlarrUser = config.users.users.prowlarr;
    in {
      DynamicUser = mkForce false;
      User = prowlarrUser.name;
      Group = prowlarrUser.group;
    };

    users = {
      users.prowlarr = {
        isSystemUser = true;
        group = "prowlarr";
        extraGroups = ["jellyfin" "qbittorrent"];
      };

      groups.prowlarr = {};
    };

    ${namespace}.services.storage.impermanence.folders = let
      prowlarrUser = config.users.users.prowlarr;
    in [
      {
        directory = "/var/lib/prowlarr";
        user = prowlarrUser.name;
        group = prowlarrUser.group;
        mode = "700";
      }
    ];
  };
}
