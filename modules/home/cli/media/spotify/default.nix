{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.media.spotify";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "spotify";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [spotify-player];

      file = {
        ".config/spotify-player/app.toml" = {
          text = ''
            theme = "tokyonight"
            client_id = "65b708073fc0480ea92a077233ca87bd"
            login_redirect_uri = "http://127.0.0.1:8989/login"
            client_port = 8080
            tracks_playback_limit = 50
            playback_format = "{status} {track} • {artists}\n{album}\n{metadata}"
            playback_metadata_fields = ["repeat", "shuffle", "volume", "device"]
            notify_format = { summary = "{track} • {artists}", body = "{album}" }
            notify_timeout_in_secs = 0
            app_refresh_duration_in_ms = 32
            playback_refresh_duration_in_ms = 0
            page_size_in_rows = 20
            enable_media_control = false
            enable_cover_image_cache = true
            enable_notify = true
            enable_streaming = "Always"
            notify_streaming_only = true
            default_device = "spotify-player"
            play_icon = "▶"
            pause_icon = "❚❚"
            liked_icon = "♥"
            cover_img_length = 9
            cover_img_width = 5
            cover_img_pixels = 16
            seek_duration_secs = 5

            [device]
            name = "spotify-player"
            device_type = "computer"
            volume = 90
            bitrate = 320
            audio_cache = false
            normalization = false
            autoplay = false

            [layout]
            library = { playlist_percent = 40, album_percent = 40 }
            playback_window_position = "Top"
            playback_window_height = 6
          '';
        };

        ".config/spotify-player/theme.toml" = {
          text = ''
            [[themes]]
            name = "tokyonight"
            [themes.palette]
            background = "#16161e"
            foreground = "#a9b1d6"
            black = "#414868"
            red = "#f7768e"
            green = "#9ece6a"
            yellow = "#e0af68"
            blue = "#7aa2f7"
            magenta = "#bb9af7"
            cyan = "#7dcfff"
            white = "#a9b1d6"
            bright_black = "#1a1b26"
            bright_red = "#db4b4b"
            bright_green = "#73daca"
            bright_yellow = "#ff9e64"
            bright_blue = "#2ac3de"
            bright_magenta = "#ff007c"
            bright_cyan = "#89ddff"
            bright_white = "#c0caf5"
          '';
        };
      };
    };
  };
}
