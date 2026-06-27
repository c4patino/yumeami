{
  lib,
  namespace,
  pkgs,
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

      media = {
        spotify = enabled;
      };

      metrics = {
        hyperfine = enabled;
      };

      tools = {
        presenterm = enabled;
        rustypaste = enabled;
      };
    };

    cli.dev.neovim.variant = "full";
  };

  programs.kitty.font.size = 14;

  wayland.windowManager.hyprland.settings.monitor = [
    {
      output = "DP-4";
      mode = "2560x1440@120";
      position = "0x0";
    }
    {
      output = "DP-4";
      mode = "2560x1440@120";
      position = "-2560x0";
    }
    {
      output = "";
      mode = "preferred";
      position = "auto-left";
      scale = "1";
    }
  ];

  home = {
    packages = with pkgs; [
      nvtopPackages.nvidia
    ];

    stateVersion = "26.05";
  };
}
