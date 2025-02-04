{
  pkgs,
  lib,
  config,
  ...
}: {
  options.teamviewer.enable = lib.mkEnableOption "Teamviewer";

  config = lib.mkIf config.teamviewer.enable {
    environment.systemPackages = with pkgs; [teamviewer];

    services.teamviewer.enable = true;
  };
}
