{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
  isEnabled = hostHasService networkCfg.network-services hostName "jellyfin";
in {
  config = mkIf isEnabled {
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };

    ${namespace}.services.storage.impermanence.folders = let
      jellyfinUser = config.users.users.jellyfin;
    in [
      "/mnt/jellyfin"
      {
        directory = "/var/lib/jellyfin";
        user = jellyfinUser.name;
        group = jellyfinUser.group;
        mode = "700";
      }
      {
        directory = "/var/cache/jellyfin";
        user = jellyfinUser.name;
        group = jellyfinUser.group;
        mode = "700";
      }
    ];
  };
}
