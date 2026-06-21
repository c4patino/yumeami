{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService resolveServicePort;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  isEnabled = hostHasService networkCfg.network-services hostName "ombi";
  port = resolveServicePort networkCfg.network-services "ombi" 5000;
in {
  config = mkIf isEnabled {
    services.ombi = {
      enable = true;
      openFirewall = true;
      port = port;
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
