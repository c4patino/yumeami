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
        asciinema = enabled;
        presenterm = enabled;
        rustypaste = enabled;
      };
    };

    desktop.env.tools.brightnessctl = enabled;

    cli.dev.neovim.variant = "full";
  };

  programs.kitty.font.size = 14;

  wayland.windowManager.hyprland.settings.monitor = [
    {
      output = "eDP-1";
      mode = "2880x1800@60";
      position = "0x0";
      scale = "1.5";
    }
    {
      output = "";
      mode = "preferred";
      position = "auto-right";
      scale = "1";
    }
  ];

  home.stateVersion = "26.05";
}
