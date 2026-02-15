{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkForce mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.services.apps.servarr.autobrr";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "autobrr";
  };

  config = mkIf cfg.enable {
    services.autobrr = {
      enable = true;
    };

    systemd.services.autobrr.serviceConfig = let
      autobrrUser = config.users.users.autobrr;
    in {
      DynamicUser = mkForce false;
      User = autobrrUser.name;
      Group = autobrrUser.group;
    };

    users = {
      users.autobrr = {
        isSystemUser = true;
        group = "autobrr";
        extraGroups = ["jellyfin" "qbittorrent"];
      };

      groups.autobrr = {};
    };

    ${namespace}.services.storage.impermanence.folders = let
      autobrrUser = config.users.users.autobrr;
    in [
      {
        directory = "/var/lib/autobrr";
        user = autobrrUser.name;
        group = autobrrUser.group;
        mode = "700";
      }
    ];
  };
}
