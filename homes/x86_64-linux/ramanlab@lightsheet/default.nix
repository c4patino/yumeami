{
  lib,
  namespace,
  pkgs,
  ...
}: let
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

  nix.settings.experimental-features = ["nix-command" "flakes" "pipe-operators"];
}
