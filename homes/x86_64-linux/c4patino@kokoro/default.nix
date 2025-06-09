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

    cli.metrics = {
      hyperfine = enabled;
    };
  };

  wayland.windowManager.hyprland.settings.monitor = [
    "eDP-1, 1920x1080@60, 0x0, 1"
    ", preferred, auto-left, 1"
  ];

  home.stateVersion = "25.11";
}
