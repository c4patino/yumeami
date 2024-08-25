{ pkgs, inputs, config, lib, ... }: {
    options = {
        network-manager.enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable network manager";
        };
    };

    config = lib.mkIf config.network-manager.enable {
        networking.networkmanager.enable = true;
    };
}
