{
  pkgs,
  config,
  lib,
  ...
}: {
  options.hyprland.enable = lib.mkEnableOption "Hyprland display manager";

  config = lib.mkIf config.hyprland.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      package = pkgs.hyprland;
    };

    environment.systemPackages = with pkgs; [xdg-desktop-portal-hyprland];

    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };

    environment.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
    };
  };
}
