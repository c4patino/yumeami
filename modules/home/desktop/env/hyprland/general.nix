{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace;
  base = "${namespace}.desktop.env.hyprland";
  cfg = getAttrByNamespace config base;
in {
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      settings = {
        exec-once = [
          "dbus-update-activation-environment --systmd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        ];

        general = {
          gaps_in = 5;
          gaps_out = 20;

          border_size = 2;
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
          resize_on_border = false;

          allow_tearing = false;

          layout = "dwindle";
        };

        decoration = {
          rounding = 10;

          active_opacity = 1.0;
          inactive_opacity = 1.0;
          fullscreen_opacity = 1.0;

          blur = {
            enabled = true;
            size = 6;
            passes = 3;
            new_optimizations = true;
          };
        };

        animations = {
          enabled = true;

          bezier = [
            "fastBezier, 0.05, 1.1, 0.2, 1.0"
            "linear, 0.0, 0.0, 1.0, 1.0"
            "liner, 1, 1, 1, 1"
          ];

          animation = [
            "windows, 1, 7, fastBezier, slide"
            "windowsOut, 1, 7, fastBezier, slide"
            "border, 1, 10, fastBezier"
            "fade, 1, 7, fastBezier"
            "workspaces, 1, 6, fastBezier"
            "border, 1, 1, liner"
            "borderangle, 1, 40, liner, loop"
            "borderangle, 1, 100, linear, loop"
          ];
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        master.new_status = "master";

        gestures.workspace_swipe = false;

        ecosystem.no_update_news = true;

        misc = {
          disable_hyprland_logo = true;
          mouse_move_enables_dpms = true;
          key_press_enables_dpms = false;
        };
      };
    };
  };
}
