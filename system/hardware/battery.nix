{
  pkgs,
  config,
  lib,
  ...
}: {
  options.battery.enable = lib.mkEnableOption "battery interfaces";

  config = lib.mkIf config.battery.enable {
    environment.systemPackages = with pkgs; [acpi];
  };
}
