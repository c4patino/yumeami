{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace;
  cfg = getAttrByNamespace config "${namespace}.desktop.env.shell.noctalia";
in {
  config = mkIf cfg.enable {
    programs.noctalia.settings = {
      theme = {
        builtin = "Tokyo-Night";

        templates = {
          enable_community_templates = false;
          enable_builtin_templates = false;
        };
      };

      wallpaper = {
        directory = "~/.assets/desktops";

        automation = {
          enabled = true;
          interval_seconds = 1800;
          order = "random";
          recursive = true;
        };
      };

      notification = {
        enable_daemon = true;
        history_retention_hours = 672;
        position = "top_right";
        show_actions = false;
        show_app_name = true;
      };

      osd = {
        enabled = true;
        position = "top_center";

        kinds.media = false;
      };

      idle = {
        behavior_order = [
          "screen-off"
          "lock"
          "lock-and-suspend"
        ];
        pre_action_fade_seconds = 2.0;

        behavior = {
          "screen-off" = {
            enabled = true;
            action = "screen_off";
            timeout = 3600.0;
          };

          "lock" = {
            enabled = false;
            action = "lock";
            timeout = 600.0;
          };

          "lock-and-suspend" = {
            enabled = false;
            action = "lock_and_suspend";
            timeout = 900.0;
          };
        };
      };

      location = {
        auto_locate = true;
      };
    };
  };
}
