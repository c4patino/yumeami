{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace;
  base = "${namespace}.desktop.env.hyprland";
  cfg = getAttrByNamespace config base;
in {
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      windowrulev2 = ["suppressevent maximize, class:.*"];
    };
  };
}
