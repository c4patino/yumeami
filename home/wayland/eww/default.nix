{ pkgs, inputs, lib, config, ... }: {
    config = lib.mkIf config.hyprland.enable {
        home.packages = with pkgs; [
            eww
            playerctl
            imagemagick
        ];

        home.file.".assets/" = {
            source = inputs.dotfiles + "/assets";
            recursive = true;
        };

        programs.eww = {
            enable = true;
            package = pkgs.eww;
            configDir = ./config;
        };
    };
}
