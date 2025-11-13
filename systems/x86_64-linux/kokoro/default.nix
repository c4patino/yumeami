{
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib.${namespace}) enabled;
in {
  imports = [
    ./hardware-configuration.nix

    inputs.disko.nixosModules.default
    (import ../../disko.nix {main = "/dev/nvme0n1";})
  ];

  ${namespace} = {
    bundles = {
      common = enabled;
      desktop = enabled;
    };

    hardware = {
      battery = enabled;
      xremap = enabled;
    };

    services = {
      apps = {
        rustypaste.client = enabled;
      };

      storage = {
        samba.mounts = {
          "shared" = "arisu";
        };
      };
    };
  };

  networking = {
    hostName = "kokoro";
    hostId = "f927bba2";
  };

  boot = {
    binfmt.emulatedSystems = ["aarch64-linux"];
    loader.grub.theme = inputs.dotfiles + "/vimix/1080p";
  };

  system.stateVersion = "25.05";
}
