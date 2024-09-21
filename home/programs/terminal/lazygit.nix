{ pkgs, lib, config, ... }: {
    options = {
        lazygit.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable lazygit";
        };
    };

    config = lib.mkIf config.lazygit.enable {
        programs.lazygit = {
			enable = true;
        };
    };
}
