{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkForce mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.services.apps.servarr.prowlarr";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "prowlarr";
  };

  config = mkIf cfg.enable {
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
