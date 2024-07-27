{ lib, config, pkgs, inputs, ... }: {
    options = {
        neovim.enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable neovim";
        };
    };

    config = lib.mkIf config.neovim.enable {
        home.packages = with pkgs; [ ripgrep ];

        programs.neovim = {
            enable = true;
            defaultEditor = true;

            viAlias = true;
            vimAlias = true;
            vimdiffAlias = true;
        };

        xdg.configFile.nvim = {
            source = inputs.neovim-config;
            recursive = true;
        };
    };
}
