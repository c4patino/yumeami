{...}: {
  imports = [
    ../global.nix
    ./stylix.nix
  ];

  anyrun.enable = true;

  music.enable = true;

  kitty.enable = true;
  leetcode.enable = true;

  browsers.enable = true;
  libreoffice.enable = true;
  obsidian.enable = true;
  postman.enable = true;
  sms.enable = true;

  hyprland.enable = true;

  wayland.windowManager.hyprland.settings.monitor = [
    "eDP-1, 1920x1080@60, 0x0, 1"
    ", preferred, -1920x0, 1"
  ];
}
