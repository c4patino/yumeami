{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace;
  inherit (config.networking) hostName;
  base = "${namespace}.bundles.common";
  cfg = getAttrByNamespace config base;
in {
  config = mkIf cfg.enable {
    users.users.c4patino = {
      isNormalUser = true;
      description = "C4 Patino";
      extraGroups = [
        "dialout"
        "docker"
        "networkmanager"
        "podman"
        "rustypaste"
        "syncthing"
        "vboxusers"
        "wheel"
      ];

      hashedPassword = "$6$XM5h391mH33WIoAy$xkeSzw/ootPPZbvHEqSguZDyB4gAeTMcjy1aRXcXcQWFkS1/SRPK27VgEYC.vYvdZLYWALZtpdEzWAfwT4VCM1";

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM9p///8yD0yoKcbgALS46ieFaJufxBcGtA2UWc6A8fv c4patino@arisu"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOpxYvrVLIttrmEKOUYlTPHHoIhToXvAwp2J9K4a+g+B c4patino@arisu-windows"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAzmJKNI3fT2nCXODsHTC3jvjXnAxHFdKdF7mQRnRrJD c4patino@kokoro"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIj2f9WyR0lEZ16fszVju8XdGLb0a7wsgUZclTIslQx+ c4patino@kokoro-windows"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDzsxorrFOF5Eq0ABSXRMh/WZwxSxs1hCMG8RnbMF6yv c4patino@chibi"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAzmJKNI3fT2nCXODsHTC3jvjXnAxHFdKdF7mQRnRrJD c4patino@kokoro"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDlOHQEPIDtc8ffn1g7fmrUGvYnKGgX4f2dQYaQ5HbV4 c4patino@shiori"
      ];

      shell = pkgs.bash;
    };

    sops = let
      inherit (config.users.users) c4patino;
    in {
      secrets = {
        "ssl/ca/cert" = {};

        "master-password" = {owner = c4patino.name;};
      };

      age.keyFile = let
        crypt = "/persist/${c4patino.home}/dotfiles/secrets/crypt";
      in "${crypt}/age/${hostName}/keys.txt";
    };
  };
}
