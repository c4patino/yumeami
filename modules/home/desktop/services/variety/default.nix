{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.desktop.services.variety";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "variety";
    };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        swaybg
        variety
      ];

      file.".assets/desktops/" = {
        source = inputs.dotfiles + "/desktops";
        recursive = true;
      };
    };

    wayland.windowManager.hyprland.settings. exec-once = [
      "swaybg &"
      "variety &"
    ];
  };
}
