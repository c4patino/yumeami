{ pkgs, lib, config, ... }: {
    options = {
        lazygit.enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable lazygit";
        };
    };

    config = lib.mkIf config.lazygit.enable {
        programs.lazygit = {
			enable = true;
        };
    };
}
