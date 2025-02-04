{
  config,
  lib,
  ...
}: {
  options.efi-bootloader.enable = lib.mkEnableOption "EFI bootloader";

  config = lib.mkIf config.efi-bootloader.enable {
    boot.loader.grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
      useOSProber = true;
    };
  };
}
