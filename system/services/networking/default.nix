{
  pkgs,
  lib,
  ...
}: {
  options = {
    network-manager.enable = lib.mkEnableOption "network manager";
  };

  imports = [
    ./httpd.nix
    ./tailscale.nix
  ];

  config = {
    environment.systemPackages = with pkgs; [networkmanagerapplet];
    networking.networkmanager.enable = true;
  };
}
