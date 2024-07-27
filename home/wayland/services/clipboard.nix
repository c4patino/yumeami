{ pkgs, lib, config, ... }: {
    config = lib.mkIf config.hyprland.enable {
        home.packages = with pkgs; [
            wl-clipboard
            cliphist
            rofi
        ];

        wayland.windowManager.hyprland = {
            settings = {
                exec-once = [
                    "wl-paste --type text --watch cliphist store"
                    "wl-paste --type image --watch cliphist store"
                ];
            };
        };
    };
}

