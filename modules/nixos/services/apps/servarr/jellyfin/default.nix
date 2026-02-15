{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.services.apps.servarr.jellyfin";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "jellyfin";
  };

  config = mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };

    ${namespace}.services.storage.impermanence.folders = let
      jellyfinUser = config.users.users.jellyfin;
    in [
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
