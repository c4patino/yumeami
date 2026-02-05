{
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkForce;
  inherit (lib.${namespace}) disabled enabled;
in {
  imports = [./stylix.nix];

  ${namespace} = {
    bundles = {
      common = disabled;

      development = enabled;
      shell = enabled;
    };

    cli.dev.neovim.variant = "minimal";
  };

  home = {
    packages = with pkgs; [
      cachix
      git
      home-manager
      nh
      nix-output-monitor
      nvd
    ];

    stateVersion = "25.11";
  };

  programs.bash = {
    enable = mkForce false;
    initExtra = mkForce "";
  };

  nix.settings = {
    experimental-features = ["nix-command" "flakes" "pipe-operators"];

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
}
