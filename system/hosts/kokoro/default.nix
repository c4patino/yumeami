{inputs, ...}: {
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
  };

  boot.binfmt.emulatedSystems = ["aarch64-linux"];
  boot.loader.grub.theme = inputs.dotfiles + "/vimix/1080p";

  audio.enable = true;
  battery.enable = true;
  bluetooth.enable = true;
  display-manager.enable = true;
  printing.enable = true;
  xremap.enable = true;

  virtualbox.enable = true;
  teamviewer.enable = true;

  hyprland.enable = true;

  samba.mounts = {
    "shared" = "arisu";
  };
}
