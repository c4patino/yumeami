{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.desktop.services.wl-clipboard";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "wl-clipboard";
    };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard
      cliphist
      rofi
    ];

    wayland.windowManager.hyprland = {
      settings = {
        exec-once = [
          "wl-paste --type text --watch cliphist store"
          "wl-paste --type image --watch cliphist store"
        ];
      };
    };
  };
}
