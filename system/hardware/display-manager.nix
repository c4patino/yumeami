{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.display-manager;
in {
  options.display-manager.enable = mkEnableOption "display managers";

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };

      displayManager.gdm = {
        enable = true;
        autoSuspend = false;
      };
    };
  };
}
