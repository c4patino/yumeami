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

      media = {
        spotify = enabled;
      };

      metrics = {
        hyperfine = enabled;
        nvtop = enabled;
      };

      tools = {
        presenterm = enabled;
      };
    };
  };

  programs.kitty.font.size = 14;

  wayland.windowManager.hyprland.settings.monitor = [
    "DP-4, 2560x1440@120, 0x0, 1"
    "DP-5, 2560x1440@120, -2560x0, 1"
    ", preferred, auto-left, 1"
  ];

  home.stateVersion = "25.11";
}
