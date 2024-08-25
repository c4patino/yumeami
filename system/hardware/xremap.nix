{ config, pkgs, lib, inputs, ... }: {
    options = {
        xremap.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable Xremap and keybind remaps";
        };
    };
    
    imports = [
        inputs.xremap.nixosModules.default
    ];

    config = {
        services.xremap = {
            userName = "c4patino";
            config.modmap = if config.xremap.enable then
                [
                    {
                        name = "Main editing remaps";
                            remap = {
                                CAPSLOCK = {
                                held = "CONTROL_L";
                                alone = "ESC";
                                alone_timeout_millis = 250;
                            };
                        };
                    }
                ]
                else
                [];
        };
    };
}
