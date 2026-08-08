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
      control_center = {
        hidden_tabs = [
          "monitor"
          "power"
        ];
        show_session_button = true;
        show_shortcut_labels = true;
        sidebar = "compact";
        sidebar_section = "compact";
        width = 900;

        calendar = {
          event_date_format = "%A %e %B";
          event_time_format = "%H:%M";
          show_events_card = true;
          show_week_numbers = false;
        };

        shortcuts = [
          {
            type = "wifi";
          }
          {
            type = "bluetooth";
          }
          {
            type = "caffeine";
          }
          {
            type = "nightlight";
          }
          {
            type = "notification";
          }
        ];
      };

      calendar = {
        enabled = true;
        refresh_minutes = 15;

        account = {
          personal = {
            calendars = [];
            color = "primary";
            credential_source = "secret-service";
            name = "";
            password_file = "";
            provider = "";
            server_url = "";
            type = "google";
            username = "";
          };
        };
      };
    };
  };
}
