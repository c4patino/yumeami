{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace mkPersistRootDir;
  base = "${namespace}.services.networking.network-manager";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "network-manager";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [networkmanagerapplet];

    networking.networkmanager.enable = true;

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistRootDir config "/etc/NetworkManager/system-connections")
    ];
  };
}
