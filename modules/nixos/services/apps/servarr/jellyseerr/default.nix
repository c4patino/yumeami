{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkForce mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.services.apps.servarr.jellyseerr";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "jellyseerr";
  };

  config = mkIf cfg.enable {
    services.jellyseerr = {
      enable = true;
      openFirewall = true;
    };

    systemd.services.jellyseerr.serviceConfig = let
      jellyseerrUser = config.users.users.jellyseerr;
    in {
      DynamicUser = mkForce false;
      User = jellyseerrUser.name;
      Group = jellyseerrUser.group;
    };

    users = {
      users.jellyseerr = {
        isSystemUser = true;
        group = "jellyseerr";
      };

      groups.jellyseerr = {};
    };

    ${namespace}.services.storage.impermanence.folders = let
      jellyseerrUser = config.users.users.jellyseerr;
    in [
      {
        directory = "/var/lib/jellyseerr";
        user = jellyseerrUser.name;
        group = jellyseerrUser.group;
        mode = "700";
      }
    ];
  };
}
