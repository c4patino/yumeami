{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkForce mkIf;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService resolveServicePort;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  isEnabled = hostHasService networkCfg.network-services hostName "bazarr";
  port = resolveServicePort networkCfg.network-services "bazarr" 6767;
in {
  config = mkIf isEnabled {
    services.bazarr = {
      enable = true;
      listenPort = port;
    };

    systemd.services.bazarr.serviceConfig = let
      bazarrUser = config.users.users.bazarr;
    in {
      DynamicUser = mkForce false;
      User = bazarrUser.name;
      Group = bazarrUser.group;
      UMask = mkForce "0002";
    };

    users = {
      users.bazarr = {
        isSystemUser = true;
        group = "bazarr";
        extraGroups = ["jellyfin" "qbittorrent"];
      };

      groups.bazarr = {};
    };

    ${namespace}.services.storage.impermanence.folders = let
      bazarrUser = config.users.users.bazarr;
    in [
      {
        directory = "/var/lib/bazarr";
        user = bazarrUser.name;
        group = bazarrUser.group;
        mode = "700";
      }
    ];
  };
}
