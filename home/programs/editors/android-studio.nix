{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.android-studio;
in {
  options.android-studio.enable = mkEnableOption "Android Studio";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [android-studio];
  };
}
