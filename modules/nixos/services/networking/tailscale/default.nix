{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace mkPersistRootDir;
  base = "${namespace}.services.networking.tailscale";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "Tailscale";
  };

  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "server";
    };

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistRootDir config "/var/lib/tailscale" "700")
    ];
  };
}
