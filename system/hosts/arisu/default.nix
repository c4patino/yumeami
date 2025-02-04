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

  audio.enable = true;
  bluetooth.enable = true;
  display-manager.enable = true;
  nvidia.enable = true;
  printing.enable = true;

  virtualbox.enable = true;
  teamviewer.enable = true;

  hyprland.enable = true;

  steam.enable = true;

  samba = {
    enable = true;
    shares = ["shared"];
  };

  github-runners = {
    enable = true;
    runners = [
      {
        name = "nixos-config";
        tokenFile = secrets."github/runner".path;
        url = "https://github.com/c4patino/nixos-config";
      }
      {
        name = "nixvim";
        tokenFile = secrets."github/runner".path;
        url = "https://github.com/c4patino/nixvim";
      }
      {
        name = "neovim";
        tokenFile = secrets."github/runner".path;
        url = "https://github.com/c4patino/neovim";
      }
      {
        name = "dotfiles";
        tokenFile = secrets."github/runner".path;
        url = "https://github.com/c4patino/dotfiles";
      }
      {
        name = "days-since";
        tokenFile = secrets."github/runner".path;
        url = "https://github.com/c4patino/days-since";
      }
      {
        name = "free-range-rust";
        tokenFile = secrets."github/runner".path;
        url = "https://github.com/c4patino/free-range-rust";
      }
      {
        name = "free-range-zoo";
        tokenFile = secrets."github/runner-oasys".path;
        url = "https://github.com/oasys-mas";
      }
    ];
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
