{
  config,
  lib,
  pkgs,
  ...
}: {
  options.network-manager.enable = lib.mkEnableOption "network manager";

  config = lib.mkIf config.network-manager.enable {
    environment.systemPackages = with pkgs; [networkmanagerapplet];
    networking.networkmanager.enable = true;
  };
}
