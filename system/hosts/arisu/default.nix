{
  inputs,
  config,
  pkgs,
  ...
}
: let
  inherit (config.sops) secrets;
in {
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

  steam.enable = true;

  audio.enable = true;
  bluetooth.enable = true;
  display-manager.enable = true;
  nvidia.enable = true;
  printing.enable = true;

  virtualbox.enable = true;
  teamviewer.enable = true;

  hyprland.enable = true;

  samba = {
    enable = true;
    shares = ["shared"];
  };

  github-runners = {
    enable = true;
    runners = {
      "nixos-config" = {url = "https://github.com/c4patino/nixos-config";};
      "nixvim" = {url = "https://github.com/c4patino/nixvim";};
      "neovim" = {url = "https://github.com/c4patino/neovim";};
      "dotfiles" = {url = "https://github.com/c4patino/dotfiles";};
      "days-since" = {url = "https://github.com/c4patino/days-since";};
      "free-range-rust" = {url = "https://github.com/c4patino/free-range-rust";};
      "free-range-zoo" = {
        tokenFile = secrets."github/runner-oasys".path;
        url = "https://github.com/oasys-mas";
      };
    };
  };

  mcservers = {
    enable = true;
    servers = {
      vanilla = {
        package = pkgs.vanillaServers.vanilla-1_21_3;
        serverProperties = {
          difficulty = "hard";
          server-port = 25565;
        };
      };
      modded = {
        package = pkgs.fabricServers.fabric-1_21_3;
        serverProperties = {
          difficulty = "hard";
          server-port = 25566;
        };
      };
    };
  };
}
