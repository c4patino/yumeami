{...}: {
  imports = [
    ../global.nix
    ./stylix.nix
  ];

  anyrun.enable = true;

  prismlauncher.enable = true;

  music.enable = true;

  kitty.enable = true;
  leetcode.enable = true;
  nvtop.enable = true;

  browsers.enable = true;
  libreoffice.enable = true;
  obsidian.enable = true;
  postman.enable = true;
  sms.enable = true;
  zotero.enable = true;

  hyprland.enable = true;

  wayland.windowManager.hyprland.settings.monitor = [
    "DP-4, 2560x1440@120, 0x0, 1"
    "DP-5, 2560x1440@120, -2560x0, 1"
    ", preferred, auto-left, 1"
  ];
}
