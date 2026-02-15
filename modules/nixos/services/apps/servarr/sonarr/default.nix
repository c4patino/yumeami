{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkForce mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.services.apps.servarr.sonarr";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "sonarr";
  };

  config = mkIf cfg.enable {
    services.sonarr = {
      enable = true;
      openFirewall = true;
    };

    systemd.services.sonarr.serviceConfig = let
      sonarrUser = config.users.users.sonarr;
    in {
      DynamicUser = mkForce false;
      User = sonarrUser.name;
      Group = sonarrUser.group;
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
