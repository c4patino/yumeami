{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.desktop.apps.launchers.walker";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "walker";
  };

  config = mkIf cfg.enable {
    services.walker = {
      enable = true;
      systemd.enable = true;
      settings = {
        app_launch_prefix = "";
        as_window = false;
        close_when_open = false;
        disable_click_to_close = false;
        force_keyboard_focus = true;
        hotreload_theme = false;
        monitor = "";
        terminal_title_flag = "";
        theme = "default";
        timeout = 0;
      };
    };
  };
}
