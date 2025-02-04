{
  lib,
  config,
  ...
}: {
  options.bluetooth.enable = lib.mkEnableOption "bluetooth support";

  config = lib.mkIf config.bluetooth.enable {
    services.blueman.enable = true;
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };
}
