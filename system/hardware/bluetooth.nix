{ lib, config, ... }: {
    options = {
        bluetooth.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable bluetooth services";
        };
    };

    config = lib.mkIf config.bluetooth.enable {
		services.blueman.enable = true;
		hardware.bluetooth = {
			enable = true;
			powerOnBoot = true;
		};
    };
}
