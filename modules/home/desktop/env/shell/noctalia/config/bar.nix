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
      bar = {
        order = [
          "default"
        ];

        default = {
          enabled = true;
          reserve_space = false;
          smart_auto_hide = true;

          start = [
            "launcher"
            "wallpaper"
            "workspaces"
          ];

          center = [
            "clock"
          ];

          end = [
            "media"
            "spacer_1"
            "notifications"
            "tray"
            "spacer_2"
            "clipboard"
            "network"
            "bluetooth"
            "volume"
            "brightness"
            "battery"
            "control-center"
          ];
        };
      };

      widget = {
        active_window = {
          icon_size = 14.0;
          max_length = 260.0;
          min_length = 80.0;
          title_scroll = "none";
          type = "active_window";
        };

        "control-center" = {
          glyph = "power";
          type = "control-center";
        };

        cpu = {
          stat = "cpu_usage";
          type = "sysmon";
        };

        date = {
          format = "{:%a %d %b}";
          type = "clock";
        };

        input_volume = {
          device = "input";
          type = "volume";
        };

        keyboard_layout = {
          hide_when_single_layout = false;
          type = "keyboard_layout";
        };

        lock_keys = {
          display = "short";
          hide_when_off = false;
          show_caps_lock = true;
          show_num_lock = true;
          show_scroll_lock = false;
          type = "lock_keys";
        };

        media = {
          art_size = 16.0;
          max_length = 220.0;
          min_length = 80.0;
          title_scroll = "none";
          type = "media";
        };

        network = {
          show_label = false;
          type = "network";
        };

        network_rx = {
          stat = "net_rx";
          type = "sysmon";
        };

        network_tx = {
          stat = "net_tx";
          type = "sysmon";
        };

        output_volume = {
          device = "output";
          type = "volume";
        };

        ram = {
          stat = "ram_used";
          type = "sysmon";
        };

        spacer = {
          interactive = false;
          type = "spacer";
        };

        spacer_1 = {
          length = 32;
          type = "spacer";
        };

        spacer_2 = {
          length = 32;
          type = "spacer";
        };

        temp = {
          stat = "cpu_temp";
          type = "sysmon";
        };
      };
    };
  };
}
