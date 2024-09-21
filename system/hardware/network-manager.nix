{ config, lib, ... }: {
    options = {
        network-manager.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable network manager";
        };
    };

    config = lib.mkIf config.network-manager.enable {
        networking.networkmanager.enable = true;
    };
}
