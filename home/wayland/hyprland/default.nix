{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.hyprland;
in {
  imports = [
    ./config/general.nix
    ./config/rules.nix
    ./config/keybinds.nix
  ];

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      xwayland.enable = true;
    };
  };
}
