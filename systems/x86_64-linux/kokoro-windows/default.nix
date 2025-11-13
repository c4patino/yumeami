{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (config.networking) hostName;
in {
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

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

  nix.settings = {
    experimental-features = ["nix-command" "flakes" "pipe-operators"];
    trusted-users = with config.users.users; [c4patino.name];

    substituters = [
      "https://cache.nixos.org"
      "https://devenv.cachix.org"
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  environment.systemPackages = with pkgs; [
    cachix
    home-manager
    nh
    nix-output-monitor
    nvd
  ];

  wsl = {
    enable = true;
    defaultUser = "c4patino";
  };

  networking = {
    hostName = "kokoro-windows";
    hostId = "98fb2503";
  };

  system.stateVersion = "25.05";
}
