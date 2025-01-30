{
  lib,
  config,
  ...
}: {
  imports = [
    ./config/general.nix
    ./config/rules.nix
    ./config/keybinds.nix
  ];

  config = lib.mkIf config.hyprland.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      xwayland.enable = true;
    };
  };
}
