{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.lastpass;
in {
  options.lastpass.enable = mkEnableOption "Lastpass CLI";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [lastpass-cli];
  };
}
