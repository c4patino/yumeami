{inputs, ...}: {
  imports = [
    ../..
    ./hardware-configuration.nix

    inputs.disko.nixosModules.default
    (import ../disko.nix {
      main = "/dev/nvme1n1";
      extras = ["/dev/nvme0n1" "/dev/nvme2n1"];
    })
  ];

  networking = {
    hostName = "arisu";
    hostId = "c6cc4687";
  };

  boot.binfmt.emulatedSystems = ["aarch64-linux"];
  boot.loader.grub.theme = inputs.dotfiles + "/vimix/4k";

  audio.enable = true;
  bluetooth.enable = true;
  display-manager.enable = true;
  nvidia.enable = true;
  printing.enable = true;

  virtualbox.enable = true;
  teamviewer.enable = true;

  github-runners.enable = true;

  hyprland.enable = true;

  steam.enable = true;
  mcservers.enable = true;

  samba = {
    enable = true;
    shares = ["shared"];
  };
}
