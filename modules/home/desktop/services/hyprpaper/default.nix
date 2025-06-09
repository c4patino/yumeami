{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.desktop.services.hyprpaper";
  cfg = getAttrByNamespace config base;

  rotateWallpaper = pkgs.writeShellScriptBin "rotate-wallpaper" ''
    WALLPAPER_DIR="$HOME/.assets/desktops"

    CURRENT_WALL=$(${pkgs.hyprland}/bin/hyprctl hyprpaper listloaded)
    CURRENT_BASE=$(basename "$CURRENT_WALL")

    WALLPAPER=$(find -L $WALLPAPER_DIR -type f ! -name "$CURRENT_BASE" | shuf -n 1)
    echo "$WALLPAPER"

    ${pkgs.hyprland}/bin/hyprctl hyprpaper reload ,"$WALLPAPER"
  '';
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "hyprpaper";
  };

  config = mkIf cfg.enable {
    services.hyprpaper = {
      enable = true;
      settings = {
        splash = false;
        ipc = true;
      };
    };

    home = {
      packages = [rotateWallpaper];

      file.".assets/desktops/" = {
        source = inputs.dotfiles + "/assets/desktops";
        recursive = true;
      };
    };

    systemd.user = {
      services.rotate-wallpaper = {
        Unit = {
          Description = "Rotate hyprland wallpaper";
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${rotateWallpaper}/bin/rotate-wallpaper";
        };
      };

      timers.rotate-wallpaper = {
        Unit = {
          Description = "Rotate wallpaper every 10 minutes";
        };
        Timer = {
          OnBootSec = "30s";
          OnUnitActiveSec = "10min";
          Unit = "rotate-wallpaper.service";
        };
        Install = {
          WantedBy = ["timers.target"];
        };
      };
    };

    wayland.windowManager.hyprland.settings.exec-once = [
      "hyprpaper &"
    ];
  };
}
