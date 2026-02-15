{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkForce mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.services.apps.servarr.bazarr";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "bazarr";
  };

  config = mkIf cfg.enable {
    services.bazarr = {
      enable = true;
    };

    systemd.services.bazarr.serviceConfig = let
      bazarrUser = config.users.users.bazarr;
    in {
      DynamicUser = mkForce false;
      User = bazarrUser.name;
      Group = bazarrUser.group;
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
