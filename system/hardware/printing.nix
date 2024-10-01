{ config, lib, ... }: {
    options = {
        printing.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable printing services";
        };
    };

    config = lib.mkIf config.printing.enable {
		services.printing.enable = true;
    };
}
