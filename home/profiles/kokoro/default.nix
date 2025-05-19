{...}: {
  imports = [
    ../global.nix
    ./stylix.nix
  ];

  anyrun.enable = true;

  android-studio.enable = true;
  clion.enable = true;
  idea.enable = true;
  pycharm.enable = true;
  rider.enable = true;

  music.enable = true;

  kitty.enable = true;
  leetcode.enable = true;

  browsers.enable = true;
  fiji.enable = true;
  libreoffice.enable = true;
  obs.enable = true;
  obsidian.enable = true;
  postman.enable = true;
  sms.enable = true;

  hyprland.enable = true;

  wayland.windowManager.hyprland.settings.monitor = [
    "eDP-1, 1920x1080@60, 0x0, 1"
    ", preferred, -1920x0, 1"
  ];
}
