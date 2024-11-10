{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.hyprland.enable {
    wayland.windowManager.hyprland.settings = {
      windowrulev2 = [
        "suppressevent maximize, class:.*"
      ];

      workspace = [
      ];
    };
  };
}
