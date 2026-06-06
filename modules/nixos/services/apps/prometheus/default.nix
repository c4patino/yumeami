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

  isEnabled = hostHasService networkCfg.network-services hostName "prometheus";
  port = getServicePort networkServices "prometheus" 9090;
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
