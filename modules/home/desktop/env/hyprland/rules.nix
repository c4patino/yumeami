{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.desktop.env.hyprland";
  cfg = getAttrByNamespace config base;
in {
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      windowrulev2 = ["suppressevent maximize, class:.*"];
    };
  };
}
