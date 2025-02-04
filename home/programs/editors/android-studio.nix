{
  pkgs,
  lib,
  config,
  ...
}: {
  options.android-studio.enable = lib.mkEnableOption "Android Studio";

  config = lib.mkIf config.android-studio.enable {
    home.packages = with pkgs; [android-studio];
  };
}
