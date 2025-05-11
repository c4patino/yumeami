{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.teamviewer;
in {
  options.teamviewer.enable = mkEnableOption "Teamviewer";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [teamviewer];

    services.teamviewer.enable = true;

    impermanence.folders = ["/var/lib/teamviewer"];
  };
}
