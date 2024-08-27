{ pkgs, inputs, config, lib, ... }: {
    options = {
        battery.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable battery interfaces";
        };
    };

    config = lib.mkIf config.battery.enable {
        environment.systemPackages = with pkgs; [
            acpi
        ];
    };
}
