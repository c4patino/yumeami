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

  isEnabled = hostHasService networkCfg.network-services hostName "sonarr";
  port = getServicePort networkServices "sonarr" 8989;
in {
  config = mkIf isEnabled {
    services.sonarr = {
      enable = true;
      settings.server.port = port;
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
