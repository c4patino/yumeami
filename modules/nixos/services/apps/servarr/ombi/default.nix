{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService resolveServicePort mkPersistDir;
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

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistDir config "ombi" "/var/lib/ombi")
    ];
  };
}
