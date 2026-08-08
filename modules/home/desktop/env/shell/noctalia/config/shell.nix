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
    programs.noctalia.settings.shell = {
      panel_anchor_bar = "default";

      launcher = {
        categories = false;
        providers.calculator = {
          global = false;
          prefix = "";
        };
      };

      password_style = "default";
      polkit_agent = true;

      panel = {
        clipboard_placement = "attached";
        open_near_click_clipboard = true;
        open_near_click_control_center = true;
        open_near_click_session = true;
        open_near_click_wallpaper = true;
      };

      session = {
        grid = true;
        actions = [
          {
            action = "shutdown";
            enabled = true;
            countdown_seconds = 0.0;
            shortcut = "5";
            variant = "destructive";
          }
          {
            action = "reboot";
            enabled = true;
            countdown_seconds = 0.0;
            shortcut = "4";
            variant = "default";
          }
          {
            action = "logout";
            enabled = true;
            countdown_seconds = 0.0;
            shortcut = "2";
            variant = "default";
          }
          {
            action = "lock";
            enabled = true;
            countdown_seconds = 0.0;
            shortcut = "1";
            variant = "default";
          }
          {
            action = "lock_and_suspend";
            enabled = false;
            countdown_seconds = 0.0;
            shortcut = "3";
            variant = "default";
          }
        ];
      };
    };
  };
}
