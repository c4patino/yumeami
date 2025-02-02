{
  self,
  pkgs,
  ...
}: {
  imports = [
    ./core
    ./gaming
    ./hardware
    ./services
    ./virtualization
    ./hyprland.nix
    ./impermanence.nix
    ./secrets.nix
  ];

  nix.settings.trusted-users = [
    "root"
    "c4patino"
  ];

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

  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;

    packages = with pkgs; [
      corefonts
      nerd-fonts.meslo-lg
      nerd-fonts.caskaydia-cove
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
    ];
  };

  systemd.tmpfiles.rules = [
    "d /mnt/sda 0755 c4patino users -"
    "d /mnt/sdb 0755 c4patino users -"
  ];

  efi-bootloader.enable = true;

  network-manager.enable = true;

  containerization.enable = true;
  slurm.enable = true;
  syncthing.enable = true;
  tailscale.enable = true;
}
