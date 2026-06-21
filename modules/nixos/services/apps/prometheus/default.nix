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

  isEnabled = hostHasService networkCfg.network-services hostName "prometheus";
  port = resolveServicePort networkCfg.network-services "prometheus" 9090;
in {
  config = mkIf isEnabled {
    services.prometheus = {
      enable = true;
      port = port;
    };

    ${namespace}.services.storage.impermanence.folders = [
      "/var/lib/prometheus2"
    ];
  };
}
