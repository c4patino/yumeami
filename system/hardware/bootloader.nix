{ pkgs, inputs, config, lib, ... }: {
    options = {
        efi-bootloader.enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable EFI bootloader";
        };
    };

    config = lib.mkIf config.efi-bootloader.enable {
        boot.loader = {
            efi = {
                canTouchEfiVariables = true;
                efiSysMountPoint = "/boot/efi";
            };
            grub = {
                enable = true;
                devices = [ "nodev" ];
                efiSupport = true;
                useOSProber = true;
            };
        };
    };
}
