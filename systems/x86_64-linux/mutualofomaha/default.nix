{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkForce;
  inherit (lib.${namespace}) disabled enabled;
in {
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

  ${namespace} = {
    bundles = {
      common = enabled;
    };

    hardware.bootloader = mkForce disabled;

    services = {
      apps = {
        slurm = {
          enable = mkForce false;
        };
      };

      networking = {
        network-manager = mkForce disabled;
        openssh = mkForce disabled;
        tailscale = mkForce disabled;
      };

      storage = {
        syncthing = mkForce disabled;
        impermanence = mkForce disabled;
      };
    };
  };

  services.resolved = {
    enable = mkForce false;
  };

  sops.age.keyFile = let
    inherit (config.networking) hostName;
    crypt = "${config.users.users.c4patino.home}/dotfiles/secrets/crypt";
  in "${crypt}/age/${hostName}/keys.txt";

  wsl = {
    enable = true;
    defaultUser = "c4patino";
  };

  services.gnome.gnome-keyring = enabled;

  security.pki.certificateFiles = [
    "${inputs.self}/secrets/crypt/ssl/zscaler.crt"
  ];

  fileSystems."/mnt/gias" = {
    device = "//file006/GIAS";
    fsType = "drvfs";
    options = ["metadata" "uid=1000" "gid=100" "umask=022"];
  };

  networking = {
    nameservers = mkForce [];

    hostName = "mutualofomaha";
    hostId = "19101c94";
  };

  system.stateVersion = "26.05";
}
