{ lib, config, ... }: {
    options = {
        zoxide.enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable zoxide";
        };
    };

    config = lib.mkIf config.zoxide.enable {
        programs.zoxide = {
            enable = true;
            enableZshIntegration = true;
            options = [ "--cmd cd" ];
        };
    };
}
