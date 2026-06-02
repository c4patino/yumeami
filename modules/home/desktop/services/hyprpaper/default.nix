{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.desktop.services.hyprpaper";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "hyprpaper";
  };

  config = mkIf cfg.enable {
    services.hyprpaper = {
      enable = true;
      settings = {
        splash = false;

        wallpaper = [
          {
            monitor = "";
            path = inputs.dotfiles + "/.assets/desktops";
            timeout = 1800;
          }
        ];
      };
    };

    wayland.windowManager.hyprland.settings.on = {
      _args = [
        "hyprland.start"
        (lib.generators.mkLuaInline ''
          function()
            hl.exec_cmd("hyprpaper")
          end
        '')
      ];
    };

    home.file.".assets/desktops/" = {
      source = inputs.dotfiles + "/.assets/desktops";
      recursive = true;
    };
  };
}
