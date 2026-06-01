{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkForce;
  inherit (lib.${namespace}) enabled disabled;
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
      ci = {
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

  sops.age.keyFile = let
    inherit (config.networking) hostName;
    crypt = "${config.users.users.c4patino.home}/dotfiles/secrets/crypt";
  in "${crypt}/age/${hostName}/keys.txt";

  wsl = {
    enable = true;
    defaultUser = "c4patino";
  };

  security.pki.certificateFiles = [
    "${inputs.self}/secrets/crypt/ssl/zscaler.crt"
  ];

  networking = {
    resolvconf.enable = mkForce false;

    hostName = "mutualofomaha";
    hostId = "19101c94";
  };

  system.stateVersion = "26.05";
}
