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
in {
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = let
      mainMod = "SUPER";

      menu =
        {
          anyrun = "GSK_RENDERER=ngl anyrun";
          walker = "walker";
        }."${launcher}" or "";

      lua = lib.generators.mkLuaInline;

      bind = keys: dispatcher: {
        _args = [keys dispatcher];
      };

      bindFlags = keys: dispatcher: flags: {
        _args = [keys dispatcher flags];
      };

      exec = cmd: lua "hl.dsp.exec_cmd(${builtins.toJSON cmd})";

      dsp = expr: lua "hl.dsp.${expr}";
    in {
      bind =
        [
          # General
          (bind "${mainMod} + T" (exec "kitty"))
          (bind "${mainMod} + R" (exec menu))
          (bind "${mainMod} + Q" (dsp "window.close()"))
          (bind "${mainMod} + ALT + Q" (dsp "exit()"))
          (bind "${mainMod} + V" (dsp "window.float({ action = \"toggle\" })"))
          (bind "${mainMod} + F" (dsp "window.fullscreen()"))
          (bind "${mainMod} + S" (dsp "layout(\"togglesplit\")"))
          (bind "${mainMod} + P" (dsp "window.pseudo()"))

          (bind "${mainMod} + Home" (exec "sh -c 'grim -g \"$(slurp -d)\" ~/Downloads/$(date +%Y-%m-%d-%H%M%S).png'"))

          # Scratchpad
          (bind "ALT + S" (dsp "workspace.toggle_special(\"magic\")"))
          (bind "ALT + SHIFT + S" (dsp "window.move({ workspace = \"special:magic\" })"))

          # Window Focus
          (bind "${mainMod} + h" (dsp "focus({ direction = \"l\" })"))
          (bind "${mainMod} + l" (dsp "focus({ direction = \"r\" })"))
          (bind "${mainMod} + k" (dsp "focus({ direction = \"u\" })"))
          (bind "${mainMod} + j" (dsp "focus({ direction = \"d\" })"))

          # Window Position
          (bind "${mainMod} + SHIFT + h" (dsp "window.move({ direction = \"l\" })"))
          (bind "${mainMod} + SHIFT + l" (dsp "window.move({ direction = \"r\" })"))
          (bind "${mainMod} + SHIFT + k" (dsp "window.move({ direction = \"u\" })"))
          (bind "${mainMod} + SHIFT + j" (dsp "window.move({ direction = \"d\" })"))

          (bindFlags "F1" (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") {
            locked = true;
          })
          (bindFlags "F2" (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-") {
            locked = true;
            repeating = true;
          })
          (bindFlags "F3" (exec "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+") {
            locked = true;
            repeating = true;
          })
          (bindFlags "F4" (exec "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle") {
            locked = true;
          })

          (bindFlags "F5" (exec "brightnessctl s 2%-") {
            locked = true;
            repeating = true;
          })
          (bindFlags "F6" (exec "brightnessctl s +2%") {
            locked = true;
            repeating = true;
          })

          (bind "F8" (exec "playerctl previous"))
          (bind "F9" (exec "playerctl play-pause"))
          (bind "F10" (exec "playerctl next"))
          (bind "F12" (exec ''sh -c 'systemctl --user is-active imx471-webcam && systemctl --user stop imx471-webcam || systemctl --user start imx471-webcam''))

          (bindFlags "${mainMod} + mouse:272" (dsp "window.drag()") {
            mouse = true;
          })
          (bindFlags "${mainMod} + mouse:273" (dsp "window.resize()") {
            mouse = true;
          })
        ]
        ++ (
          10
          |> builtins.genList (i: let
            key =
              if i == 9
              then "0"
              else toString (i + 1);

            ws =
              if i == 9
              then "10"
              else toString (i + 1);
          in [
            (bind "${mainMod} + ${key}" (dsp "focus({ workspace = ${ws}; })"))
            (bind "${mainMod} + SHIFT + ${key}" (dsp "window.move({ workspace = ${ws}; })"))
          ])
          |> builtins.concatLists
        );
    };
  };
}
