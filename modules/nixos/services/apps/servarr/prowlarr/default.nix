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

  isEnabled = hostHasService networkCfg.network-services hostName "prowlarr";
  port = getServicePort networkServices "prowlarr" 9696;
in {
  config = mkIf isEnabled {
    services.prowlarr = {
      enable = true;
      settings.server.port = port;
    };

    systemd.services.prowlarr.serviceConfig = let
      prowlarrUser = config.users.users.prowlarr;
    in {
      DynamicUser = mkForce false;
      User = prowlarrUser.name;
      Group = prowlarrUser.group;
      UMask = mkForce "0002";
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
