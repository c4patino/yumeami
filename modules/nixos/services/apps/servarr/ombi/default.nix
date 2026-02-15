{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.services.apps.servarr.ombi";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "ombi";
  };

  config = mkIf cfg.enable {
    services.ombi = {
      enable = true;
      openFirewall = true;
    };

    users = {
      users.ombi = {
        isSystemUser = true;
        group = "ombi";
      };

      groups.ombi = {};
    };

    ${namespace}.services.storage.impermanence.folders = let
      ombiUser = config.users.users.ombi;
    in [
      {
        directory = "/var/lib/ombi";
        user = ombiUser.name;
        group = ombiUser.group;
        mode = "700";
      }
    ];
  };
}
