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
    (import ../../disko.nix {main = "/dev/mmcblk1";})
  ];

  ${namespace} = {
    bundles = {
      common = enabled;
      server = enabled;
    };

    services = {
      storage = {
        nfs = {
          enable = true;
          shares = [
            {
              name = "slurm";
              whitelist = ["arisu"];
            }
          ];
        };
      };
    };
  };

  networking = {
    hostName = "chibi";
    hostId = "9245f27e";
  };

  boot.loader = {
    efi.canTouchEfiVariables = mkForce false;
    grub.efiInstallAsRemovable = true;
  };

  system.stateVersion = "26.05";
}
