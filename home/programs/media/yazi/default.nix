{ config, pkgs, lib, inputs, ... }: {
    options = {
        yazi.enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable yazi";
        };
    };

    imports = [
        ./keymap.nix 
        ./openers.nix
        ./zathura.nix
    ];

    config = lib.mkIf config.yazi.enable {
        home.packages = with pkgs; [
            mpv
            imv
            jq
            exiftool
			pandoc
        ];


        programs.yazi = {
            enable = true;
            package = pkgs.yazi;
            enableZshIntegration = true;
            settings = {
                manager = {
                    ratio = [1 3 3];
                    sort_by = "natural";
                    sort_reverse = false;
                    sort_dir_first = true;
                    show_hidden = true;
                    show_symlink = true;
                    linemode = "size";
                };
                preview = {
                    cache_dir = "${config.xdg.cacheHome}";
                    max_height = 900;
                    max_width = 600;
                };
                log.enable = false;
            };
        };
    };
}
