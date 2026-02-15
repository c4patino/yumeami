{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkForce mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.services.apps.servarr.radarr";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "radarr";
  };

  config = mkIf cfg.enable {
    services.radarr = {
      enable = true;
      openFirewall = true;
    };

    systemd.services.radarr.serviceConfig = let
      radarrUser = config.users.users.radarr;
    in {
      DynamicUser = mkForce false;
      User = radarrUser.name;
      Group = radarrUser.group;
    };

    users = {
      users.radarr = {
        isSystemUser = true;
        group = "radarr";
        extraGroups = ["jellyfin" "qbittorrent"];
      };

      groups.radarr = {};
    };

    ${namespace}.services.storage.impermanence.folders = let
      radarrUser = config.users.users.radarr;
    in [
      {
        directory = "/var/lib/radarr";
        user = radarrUser.name;
        group = radarrUser.group;
        mode = "700";
      }
    ];
  };
}
