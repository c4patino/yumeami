{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkForce mkIf;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService flattenHostServices getServicePort;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
  networkServices = flattenHostServices networkCfg.network-services;

  isEnabled = hostHasService networkCfg.network-services hostName "seerr";
  port = getServicePort networkServices "seerr" 5055;
in {
  config = mkIf isEnabled {
    services.seerr = {
      enable = true;
      port = port;
      openFirewall = true;
    };

    systemd.services.seerr.serviceConfig = let
      seerrUser = config.users.users.seerr;
    in {
      DynamicUser = mkForce false;
      User = seerrUser.name;
      Group = seerrUser.group;
    };

    users = {
      users.seerr = {
        isSystemUser = true;
        group = "seerr";
      };

      groups.seerr = {};
    };

    ${namespace}.services.storage.impermanence.folders = let
      seerrUser = config.users.users.seerr;
    in [
      {
        directory = "/var/lib/seerr";
        user = seerrUser.name;
        group = seerrUser.group;
        mode = "700";
      }
    ];
  };
}
