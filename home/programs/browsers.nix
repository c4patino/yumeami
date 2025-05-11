{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.browsers;
in {
  options.browsers.enable = mkEnableOption "common browers";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [vivaldi];
  };
}
