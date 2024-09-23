{ config, lib, ... }: {
    options = {
        display-manager.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable display managers";
        };
    };

    config = lib.mkIf config.display-manager.enable {
		services.xserver = {
            enable = true;
            xkb = {
                layout = "us";
                variant = "";
            };

            displayManager.gdm.enable = true;
        };
    };
}
