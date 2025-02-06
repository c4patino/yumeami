{...}: {
  imports = [
    ./stylix.nix
  ];

  anyrun.enable = true;

  android-studio.enable = true;
  idea.enable = true;
  pycharm.enable = true;

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
    ", preferred, auto, 1"
  ];
}
