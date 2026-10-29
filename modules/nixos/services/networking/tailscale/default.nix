{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkBoolOpt mkOptionsWithNamespace mkPersistRootDir;
  base = "${namespace}.services.networking.tailscale";
  cfg = getAttrByNamespace config base;
in {
  imports = [
    ./recovery.nix
  ];

  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "Tailscale";

    recovery = {
      enable = mkBoolOpt false "Whether to periodically check Tailscale control-plane connectivity.";
    };
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
