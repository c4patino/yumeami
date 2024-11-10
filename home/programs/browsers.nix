{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    browsers.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable browsers";
    };
  };

  config = lib.mkIf config.browsers.enable {
    home.packages = with pkgs; [
      # (google-chrome.override {
      #     commandLineArgs = [ "--enable-features=UseOzonePlatform" "--ozone-platform=wayland" ];
      # })

      vivaldi
    ];
  };
}
