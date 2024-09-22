{ config, lib, ... }: {
    options = {
        nvidia.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable NVIDIA GPU support";
        };
    };

    config = lib.mkIf config.nvidia.enable {
        hardware.graphics = {
            enable = true;
            enable32Bit = true;
        };

        services.xserver.videoDrivers = [ "nvidia" ];

        hardware.nvidia = {
            modesetting.enable = true;
            powerManagement.enable = false;
            powerManagement.finegrained = false;

            open = false;

            nvidiaSettings = true;

            package = config.boot.kernelPackages.nvidiaPackages.stable;
        };
    };
}
