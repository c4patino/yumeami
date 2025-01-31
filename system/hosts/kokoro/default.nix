{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../..
    ./hardware-configuration.nix

    inputs.disko.nixosModules.default
    (import ../disko.nix {
      main = "/dev/nvme0n1";
      extras = [];
    })
  ];

  networking = {
    hostName = "kokoro";
    hostId = "f927bba2";
    networkmanager.enable = true;
  };

  users.users.c4patino = {
    isNormalUser = true;
    description = "C4 Patino";
    extraGroups = ["networkmanager" "wheel" "vboxusers" "docker" "podman" "syncthing"];
    hashedPassword = "$6$XM5h391mH33WIoAy$xkeSzw/ootPPZbvHEqSguZDyB4gAeTMcjy1aRXcXcQWFkS1/SRPK27VgEYC.vYvdZLYWALZtpdEzWAfwT4VCM1";
    shell = pkgs.zsh;
  };

  boot.binfmt.emulatedSystems = ["aarch64-linux"];
  boot.loader.grub.theme = inputs.dotfiles + "/vimix/1080p";

  audio.enable = true;
  battery.enable = true;
  bluetooth.enable = true;
  efi-bootloader.enable = true;
  display-manager.enable = true;
  network-manager.enable = true;
  printing.enable = true;
  xremap.enable = true;

  slurm.enable = true;
  syncthing.enable = true;
  tailscale.enable = true;

  containerization.enable = true;
  virtualbox.enable = true;
  teamviewer.enable = true;

  hyprland.enable = true;
}
