{
  pkgs,
  lib,
  config,
  ...
}: {
  options.browsers.enable = lib.mkEnableOption "common browers";

  config = lib.mkIf config.browsers.enable {
    home.packages = with pkgs; [vivaldi];
  };
}
