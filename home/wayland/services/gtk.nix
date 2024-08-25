{ pkgs, config, lib, ... }: 
let
    gruvboxPlus = import ../../../derivations/gruvbox-plus.nix { inherit pkgs; };
in
{
    config = lib.mkIf config.hyprland.enable {
        qt = {
            enable = true;
            platformTheme.name = "gtk";
        };

        gtk = {
            enable = true;
            theme = {
                package = pkgs.adw-gtk3;
                name = "adw-gtk3";
            };
            iconTheme = {
                package = gruvboxPlus;
                name = "GruvboxPlus";
            };
        };
    };
}
