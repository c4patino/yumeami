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
    (import ../disko.nix {
      main = "/dev/mmcblk1";
      extras = [];
    })
  ];

  networking = {
    hostName = "chibi";
    hostId = "9245f27e";
  };

  users.users.c4patino = {
    isNormalUser = true;
    description = "C4 Patino";
    extraGroups = ["networkmanager" "wheel" "vboxusers" "docker" "podman" "syncthing"];

    hashedPassword = "$6$XM5h391mH33WIoAy$xkeSzw/ootPPZbvHEqSguZDyB4gAeTMcjy1aRXcXcQWFkS1/SRPK27VgEYC.vYvdZLYWALZtpdEzWAfwT4VCM1";

    openssh.authorizedKeys.keyFiles = [
      "${self}/secrets/crypt/arisu/id_ed25519.pub"
      "${self}/secrets/crypt/kokoro/id_ed25519.pub"
      "${self}/secrets/crypt/chibi/id_ed25519.pub"
    ];

    shell = pkgs.zsh;
  };

  efi-bootloader.enable = true;

  network-manager.enable = true;

  containerization.enable = true;

  pm2.enable = true;
  slurm.enable = true;
  syncthing.enable = true;
  tailscale.enable = true;
}
