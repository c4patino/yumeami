{
  config,
  lib,
  ...
}: {
  options = {
    efi-bootloader.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable EFI bootloader";
    };
  };

  config = lib.mkIf config.efi-bootloader.enable {
    boot.loader.grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
      useOSProber = true;
    };
  };
}
