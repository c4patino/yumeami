{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./eww
    ./hyprland
    ./services/gtk.nix
    ./services/clipboard.nix
    ./services/mako.nix
    ./services/variety.nix
  ];

  options = {
    hyprland.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Hyprland window manager";
    };
  };

  config = lib.mkIf config.hyprland.enable {
    home.packages = with pkgs; [
      (waybar.overrideAttrs (oldAttrs: {mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];}))

      hyprpicker
      grim
      slurp
      wl-clipboard
    ];

    wayland.windowManager.hyprland = {
      settings = {
        env = [
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
  };
}
