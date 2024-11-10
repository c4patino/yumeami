{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    android-studio.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enables Android Studio";
    };
  };

  config = lib.mkIf config.android-studio.enable {
    home.packages = with pkgs; [android-studio];
  };
}
