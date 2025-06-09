{
  config,
  lib,
  namespace,
  pkgs,
  ...
} @ args: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.desktop.env.hyprland";
  cfg = getAttrByNamespace config base;
in {
  imports = [
    (import ./general.nix args)
    (import ./keybinds.nix args)
    (import ./rules.nix args)
  ];

  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "Hyprland";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [hyprpicker hyprpaper];

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      xwayland.enable = true;

      settings.env = [
        "GDK_BACKEND,wayland,x11,*"
        "QT_QPA_PlATFORM,wayland;xcb"
        "SDLVIDEODRIVER,wayland"
        "CLUTTER_BACKEND,wayland"
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"

        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "QT_QPA_PLATOFMR,wayland;xcb"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_QPA_PLATFORMTHEME,qt5ct"

        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"

        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "LIBVA_DRIVER_NAME,nvidia"
      ];
    };
  };
}
