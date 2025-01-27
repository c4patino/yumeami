{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../..
    ./hardware-configuration.nix

    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];

  networking = {
    hostName = "chibi";
    hostId = "9245f27e";
  };

  users.users.c4patino = {
    isNormalUser = true;
    description = "C4 Patino";
    extraGroups = ["networkmanager" "wheel" "docker" "syncthing"];
    hashedPassword = "$6$XM5h391mH33WIoAy$xkeSzw/ootPPZbvHEqSguZDyB4gAeTMcjy1aRXcXcQWFkS1/SRPK27VgEYC.vYvdZLYWALZtpdEzWAfwT4VCM1";
    shell = pkgs.zsh;
  };

  network-manager.enable = true;

  docker.enable = true;

  pm2.enable = true;
  slurm.enable = true;
  syncthing.enable = true;
  tailscale.enable = true;
}
