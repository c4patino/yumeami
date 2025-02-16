{...}: {
  imports = [
    ./stylix.nix
  ];

  anyrun.enable = true;

  android-studio.enable = true;
  idea.enable = true;
  pycharm.enable = true;
  rider.enable = true;

  prismlauncher.enable = true;

  music.enable = true;

  kitty.enable = true;
  leetcode.enable = true;
  nvtop.enable = true;

  browsers.enable = true;
  fiji.enable = true;
  libreoffice.enable = true;
  obs.enable = true;
  obsidian.enable = true;
  postman.enable = true;
  sms.enable = true;

  hyprland.enable = true;

  wayland.windowManager.hyprland.settings.monitor = [
    "DP-1, 2560x1440@120, 0x0, 1"
    "DP-2, 2560x1440@120, 2560x0, 1"
    ", preferred, auto, 1"
  ];
}
