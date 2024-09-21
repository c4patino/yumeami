{ pkgs, inputs, config, lib, ... }: {
    options = {
        hyprland.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable hyprland";
        };
    };

    config = lib.mkIf config.hyprland.enable {
        programs.hyprland = {
            enable = true;
            package = inputs.hyprland.packages."${pkgs.system}".hyprland;
            xwayland.enable = true;
        };

        environment.systemPackages = with pkgs; [ 
            xdg-desktop-portal-hyprland
        ];

        xdg.portal = {
            enable = true;
            extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
        };

        environment.sessionVariables = {
            WLR_NO_HARDWARE_CURSORS = "1";
            NIXOS_OZONE_WL = "1";
        };
    };
}
