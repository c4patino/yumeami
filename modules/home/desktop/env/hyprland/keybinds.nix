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

  launcherCfg = getAttrByNamespace config "${namespace}.desktop.apps.launchers";
  launcher = launcherCfg.launcher;
  menuCmd =
    if launcher == "anyrun"
    then "GSK_RENDERER=ngl anyrun"
    else if launcher == "walker"
    then "walker"
    else "";
in {
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      "$mainMod" = "SUPER";
      "$terminal" = "kitty";
      "$menu" = menuCmd;

      bind = [
        # General
        "$mainMod, T, exec, $terminal"
        "$mainMod, R, exec, $menu"
        "$mainMod, Q, killactive,"
        "$mainMod ALT, Q, exit,"
        "$mainMod, V, togglefloating,"
        "$mainMod, F, fullscreen,"
        "$mainMod, P, pseudo,"
        "$mainMod, S, togglesplit,"

        "$mainMod, Home, exec, sh -c 'grim -g \"$(slurp -d)\" ~/Downloads/$(date +%Y-%m-%d-%H%M%S).png'"

        # Scratchpad
        "ALT, S, exec, scratchpad"
        "ALT SHIFT, S, movetoworkspace, special:magic"

        # Window focus
        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, k, movefocus, u"
        "$mainMod, j, movefocus, d"

        # Window position
        "$mainMod SHIFT, h, movewindow, l"
        "$mainMod SHIFT, l, movewindow, r"
        "$mainMod SHIFT, k, movewindow, u"
        "$mainMod SHIFT, j, movewindow, d"

        # Switch workspaces with mainMod + [0-9]
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # System
        ", F8, exec, playerctl previous"
        ", F9, exec, playerctl play-pause"
        ", F10, exec, playerctl next"
      ];

      bindl = [
        ", F1, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];

      bindle = [
        ", F2, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", F3, exec, wpctl set-volume -l 1.2 @DEFAULT_AUDIO_SINK@ 5%+"
        ", F4, exec, wpctl set-mute -l 1.2 @DEFAULT_AUDIO_SOURCE@ toggle"
        ", F5, exec, brightnessctl s 2%-"
        ", F6, exec, brightnessctl s +2%"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };
}
