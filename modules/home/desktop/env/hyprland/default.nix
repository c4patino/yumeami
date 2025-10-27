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
        "CLUTTER_BACKEND,wayland"
        "GBM_BACKEND,nvidia-drm"
        "GDK_BACKEND,wayland,x11,*"
        "GTK_USE_PORTAL,1"
        "HYPRCURSOR_SIZE,24"
        "LIBVA_DRIVER_NAME,nvidia"
        "NIXOS_OZONE_WL,1"
        "QT_QPA_PlATFORM,wayland;xcb"
        "SDLVIDEODRIVER,wayland"
        "XCURSOR_SIZE,24"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"

        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "QT_QPA_PLATFORMTHEME,qt5ct"
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"

        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
      ];
    };
  };
}
