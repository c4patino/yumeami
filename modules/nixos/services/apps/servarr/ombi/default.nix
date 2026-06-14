{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService flattenHostServices getServicePort;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
  networkServices = flattenHostServices networkCfg.network-services;

  isEnabled = hostHasService networkCfg.network-services hostName "ombi";
  port = getServicePort networkServices "ombi" 5000;
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
