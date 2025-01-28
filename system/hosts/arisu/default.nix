{
  self,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../..
    ./hardware-configuration.nix

    inputs.disko.nixosModules.default
    (import ./disko.nix {
      main = "/dev/nvme1n1";
      extras = ["/dev/nvme0n1" "/dev/nvme2n1"];
    })
  ];

  networking = {
    hostName = "arisu";
    hostId = "c6cc4687";
    networkmanager.enable = true;
  };

  users.users.c4patino = {
    isNormalUser = true;
    description = "C4 Patino";
    extraGroups = ["networkmanager" "wheel" "vboxusers" "docker" "podman" "syncthing"];

    hashedPassword = "$6$XM5h391mH33WIoAy$xkeSzw/ootPPZbvHEqSguZDyB4gAeTMcjy1aRXcXcQWFkS1/SRPK27VgEYC.vYvdZLYWALZtpdEzWAfwT4VCM1";

    openssh.authorizedKeys.keyFiles = [
      "${self}/secrets/crypt/ssh/arisu/id_ed25519.pub"
      "${self}/secrets/crypt/ssh/kokoro/id_ed25519.pub"
      "${self}/secrets/crypt/ssh/chibi/id_ed25519.pub"
    ];

    shell = pkgs.zsh;
  };

  boot.binfmt.emulatedSystems = ["aarch64-linux"];
  boot.loader.grub.theme = inputs.dotfiles + "/vimix/4k";

  audio.enable = true;
  bluetooth.enable = true;
  efi-bootloader.enable = true;
  display-manager.enable = true;
  network-manager.enable = true;
  nvidia.enable = true;
  printing.enable = true;

  containerization.enable = true;
  virtualbox.enable = true;
  teamviewer.enable = true;

  github-runners.enable = true;
  samba.enable = true;
  slurm.enable = true;
  syncthing.enable = true;
  tailscale.enable = true;

  hyprland.enable = true;

  steam.enable = true;
  mcservers.enable = true;
}
