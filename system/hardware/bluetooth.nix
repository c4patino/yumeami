{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.bluetooth;
in {
  options.bluetooth.enable = mkEnableOption "bluetooth support";

  config = mkIf cfg.enable {
    services.blueman.enable = true;
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    impermanence.folders = ["/var/lib/bluetooth"];
  };
}
