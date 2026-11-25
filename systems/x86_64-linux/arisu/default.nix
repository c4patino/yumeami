{
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkForce;
  inherit (lib.${namespace}) enabled;
in {
  imports = [
    ./hardware-configuration.nix

    inputs.disko.nixosModules.default
    (import ../../disko.nix {
      main = "/dev/nvme0n1";
      extras = [
        "/dev/nvme1n1"
        "/dev/nvme2n1"
      ];
    })
  ];

  ${namespace} = {
    bundles = {
      common = enabled;
      homelab = enabled;
      desktop = enabled;
    };

    hardware = {
      nvidia = enabled;
    };

    services = {
      ci = {
        #  TODO: re-enable this and switch this module to use the new
        #  forgejo-runner keys once switching to 26.11
        # gitea-runner = {
        #   enable = true;
        #   runners."default" = {};
        # };
        woodpecker.runners.primary = {
          enable = true;
        };
      };

      storage = {
        samba = {
          enable = true;
          shares = ["shared"];
        };
        nfs = {
          enable = true;
          shares = [
            {
              name = "autobrr";
              whitelist = ["shiori"];
            }
          ];
        };
      };

      networking = {
        httpd = enabled;
        registry.chibi.blocky.priority = mkForce 128;
      };
    };
  };

  networking = {
    hostName = "arisu";
    hostId = "c6cc4687";
  };

  boot = {
    binfmt = {
      emulatedSystems = ["aarch64-linux"];
      preferStaticEmulators = true;
    };
    loader.grub = {
      theme = inputs.dotfiles + "/vimix/4k";
      useOSProber = true;
    };
  };
}
