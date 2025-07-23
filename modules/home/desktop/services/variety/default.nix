{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.desktop.services.variety";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "variety";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        swaybg
        variety
      ];

      file.".assets/desktops/" = {
        source = inputs.dotfiles + "/.assets/desktops";
        recursive = true;
      };
    };

    wayland.windowManager.hyprland.settings. exec-once = [
      "swaybg &"
      "variety &"
    ];
  };
}
