{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkForce mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.services.apps.servarr.readarr";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "readarr";
  };

  config = mkIf cfg.enable {
    services.readarr = {
      enable = true;
      openFirewall = true;
    };

    systemd.services.readarr.serviceConfig = let
      readarrUser = config.users.users.readarr;
    in {
      DynamicUser = mkForce false;
      User = readarrUser.name;
      Group = readarrUser.group;
    };

    users = {
      users.readarr = {
        isSystemUser = true;
        group = "readarr";
        extraGroups = ["jellyfin" "qbittorrent"];
      };

      groups.readarr = {};
    };

    ${namespace}.services.storage.impermanence.folders = let
      readarrUser = config.users.users.readarr;
    in [
      {
        directory = "/var/lib/readarr";
        user = readarrUser.name;
        group = readarrUser.group;
        mode = "700";
      }
    ];
  };
}
