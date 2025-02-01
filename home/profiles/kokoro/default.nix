{...}: {
  imports = [
    ./stylix.nix
  ];

  hyprland.enable = true;
  kitty.enable = true;
  anyrun.enable = true;

  music.enable = true;
  leetcode.enable = true;

  android-studio.enable = true;
  pycharm.enable = true;
  idea.enable = true;

  browsers.enable = true;
  fiji.enable = true;
  libreoffice.enable = true;
  obs.enable = true;
  obsidian.enable = true;
  postman.enable = true;
  sms.enable = true;

  wayland.windowManager.hyprland.settings.monitor = [
    ", preferred, auto, 1"
  ];
}
