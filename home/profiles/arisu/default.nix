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
    "DP-4, 2560x1440@120, 0x0, 1"
    "DP-5, 2560x1440@120, -2560x0, 1"
    ", preferred, -5120x0, 1"
  ];
}
