{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.battery;
in {
  options.battery.enable = mkEnableOption "battery interfaces";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [acpi];
  };
}
