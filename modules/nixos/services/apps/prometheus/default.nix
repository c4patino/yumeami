{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService mkPersistDir resolveServicePort waitForNetwork;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  isEnabled = hostHasService networkCfg.registry hostName "prometheus";
  port = resolveServicePort networkCfg.registry "prometheus" 9090;
in {
  config = mkIf isEnabled {
    services.prometheus = {
      enable = true;
      port = port;
    };

    systemd.services.prometheus = waitForNetwork;

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistDir config "prometheus" "/var/lib/prometheus2" "700")
    ];
  };
}
