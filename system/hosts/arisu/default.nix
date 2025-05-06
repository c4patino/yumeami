{
  inputs,
  config,
  ...
}: {
  imports = [
    ../global.nix
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
  hyprland.enable = true;
  nvidia.enable = true;
  printing.enable = true;

  steam.enable = true;

  httpd.enable = true;

  rustypaste.enable = true;
  glance.enable = true;

  nfs.mounts = {
    "slurm" = "chibi";
  };

  samba = {
    enable = true;
    shares = ["shared"];
  };

  github-runners = let
    inherit (config.sops) secrets;
  in {
    enable = true;
    runners = {
      "nixos-config" = {url = "https://github.com/c4patino/nixos-config";};
      "nixvim" = {url = "https://github.com/c4patino/nixvim";};
      "neovim" = {url = "https://github.com/c4patino/neovim";};
      "dotfiles" = {url = "https://github.com/c4patino/dotfiles";};
      "days-since" = {url = "https://github.com/c4patino/days-since";};
      "oasys-experiments" = {url = "https://github.com/c4patino/oasys-experiments";};
      "oasys-mas" = {
        tokenFile = secrets."github/runner-oasys".path;
        url = "https://github.com/oasys-mas";
      };
    };
  };
}
