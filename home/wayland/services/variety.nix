{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: {
  config = lib.mkIf config.hyprland.enable {
    home = {
      packages = with pkgs; [
        swaybg
        variety
      ];

      file.".desktops/" = {
        source = inputs.dotfiles + "/desktops";
        recursive = true;
      };
    };

    wayland.windowManager.hyprland = {
      settings = {
        exec-once = [
          "swaybg &"
          "variety &"
        ];
      };
    };
  };
}
