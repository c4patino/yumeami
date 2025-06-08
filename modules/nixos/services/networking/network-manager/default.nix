{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.services.networking.network-manager";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "network-manager";
    };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [networkmanagerapplet];

    networking.networkmanager.enable = true;

    ${namespace}.services.storage.impermanence.folders = ["/etc/NetworkManager/system-connections"];
  };
}
