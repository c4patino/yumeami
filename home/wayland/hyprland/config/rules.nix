{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.hyprland;
in {
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      windowrulev2 = [
        "suppressevent maximize, class:.*"
      ];

      workspace = [
      ];
    };
  };
}
