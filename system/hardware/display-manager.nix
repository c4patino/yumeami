{
  config,
  lib,
  ...
}: {
  options.display-manager.enable = lib.mkEnableOption "display managers";

  config = lib.mkIf config.display-manager.enable {
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
