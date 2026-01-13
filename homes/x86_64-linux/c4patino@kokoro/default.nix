{
  lib,
  namespace,
  ...
}: let
  inherit (lib.${namespace}) enabled;
in {
  imports = [./stylix.nix];

  ${namespace} = {
    bundles = {
      common = enabled;

      desktop = {
        enable = true;
        applications = enabled;
      };

      development = enabled;
      shell = enabled;
    };

    cli = {
      access = {
        bitwarden = enabled;
      };

      dev = {
        leetcode = enabled;
      };

      metrics = {
        hyperfine = enabled;
      };

      tools = {
        presenterm = enabled;
      };
    };

    desktop.services.brightnessctl = enabled;

    cli.dev.neovim.variant = "full";
  };

  programs.kitty.font.size = 14;

  wayland.windowManager.hyprland.settings.monitor = [
    "eDP-1, 1920x1080@60, 0x0, 1"
    ", preferred, auto-left, 1"
  ];

  home.stateVersion = "25.11";
}
