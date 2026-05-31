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
  isEnabled = hostHasService networkCfg.network-services hostName "autobrr";
in {
  config = mkIf isEnabled {
    services.autobrr = {
      enable = true;
    };

    systemd.services.autobrr.serviceConfig = let
      autobrrUser = config.users.users.autobrr;
    in {
      DynamicUser = mkForce false;
      User = autobrrUser.name;
      Group = autobrrUser.group;
      UMask = mkForce "0002";
    };

    users = {
      users.autobrr = {
        isSystemUser = true;
        group = "autobrr";
        extraGroups = ["jellyfin" "qbittorrent"];
      };

      groups.autobrr = {};
    };

    ${namespace}.services.storage.impermanence.folders = let
      autobrrUser = config.users.users.autobrr;
    in [
      {
        directory = "/var/lib/autobrr";
        user = autobrrUser.name;
        group = autobrrUser.group;
        mode = "700";
      }
    ];
  };
}
