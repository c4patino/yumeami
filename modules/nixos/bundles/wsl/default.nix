{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkForce mkIf;
  inherit (lib.${namespace}) disabled enabled getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.bundles.wsl";
  cfg = getAttrByNamespace config base;
in {
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "wsl bundle";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
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
          impermanence = mkForce disabled;
          syncthing = mkForce disabled;
        };
      };
    };

    services = {
      gnome.gnome-keyring = enabled;
      resolved.enable = mkForce false;
    };

    sops.age.keyFile = let
      inherit (config.networking) hostName;
      crypt = "${config.users.users.c4patino.home}/dotfiles/secrets/crypt";
    in "${crypt}/age/${hostName}/keys.txt";

    wsl = {
      enable = true;
      defaultUser = "c4patino";
    };

    networking.nameservers = mkForce [];
  };
}
