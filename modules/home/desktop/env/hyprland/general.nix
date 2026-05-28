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
    wayland.windowManager.hyprland.settings = {
      on = {
        _args = [
          "hyprland.start"
          (lib.generators.mkLuaInline ''
            function()
              hl.exec_cmd("systemctl --user start ${pkgs.hyprpolkitagent}/bin/hyprpolkitagent")
            end
          '')
        ];
      };

      config = {
        general = {
          gaps_in = 5;
          gaps_out = 20;

          border_size = 2;
          "col.active_border" = {
            colors = [
              "rgba(33ccffee)"
              "rgba(00ff99ee)"
            ];

            angle = 45;
          };
          "col.inactive_border" = {
            colors = [
              "rgba(595959aa)"
            ];

            angle = 45;
          };

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
        };

        dwindle = {
          preserve_split = true;
        };

        xwayland = {
          enabled = true;
          force_zero_scaling = true;
        };

        misc = {
          disable_hyprland_logo = true;
          mouse_move_enables_dpms = true;
          key_press_enables_dpms = false;
        };

        input.touchpad.disable_while_typing = true;

        ecosystem = {
          no_update_news = true;
          no_donation_nag = true;
        };
      };

      curve = let
        mkBezier = name: x0: y0: x1: y1: {
          _args = [
            name
            {
              type = "bezier";
              points = [
                [x0 y0]
                [x1 y1]
              ];
            }
          ];
        };
      in [
        (mkBezier "fastBezier" 0.05 1.1 0.2 1.0)
        (mkBezier "linear" 0.0 0.0 1.0 1.0)
        (mkBezier "liner" 1 1 1 1)
      ];

      animation = let
        mkAnimation = leaf: enabled: speed: bezier: style:
          {
            inherit leaf enabled speed bezier;
          }
          // lib.optionalAttrs (style != null) {
            inherit style;
          };

        mkAnimation' = leaf: speed: bezier: style:
          mkAnimation leaf true speed bezier style;
      in [
        (mkAnimation' "windows" 7 "fastBezier" "slide")
        (mkAnimation' "windowsOut" 7 "fastBezier" "slide")
        (mkAnimation' "border" 10 "fastBezier" null)
        (mkAnimation' "fade" 7 "fastBezier" null)
        (mkAnimation' "workspaces" 6 "fastBezier" null)
        (mkAnimation' "border" 1 "liner" null)
        (mkAnimation' "borderangle" 40 "liner" "loop")
        (mkAnimation' "borderangle" 100 "linear" "loop")
      ];
    };
  };
}
