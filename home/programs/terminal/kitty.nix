{ pkgs, lib, config, ... }: {
    options = {
        kitty.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable the kitty terminal emulator";
        };
    };

    config = lib.mkIf config.kitty.enable {
        programs.kitty = {
            enable = true;
            shellIntegration.enableZshIntegration = true;
            font.name = "MesloLGM Nerd Font Mono";

            keybindings = {
                "ctrl+enter" = "new_window_with_cwd";
            };

            extraConfig = ''
                enabled_layouts grid, fat
            '';
        };
    };
}
