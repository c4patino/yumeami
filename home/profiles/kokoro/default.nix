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
  zotero.enable = true;

  hyprland.enable = true;

  wayland.windowManager.hyprland.settings.monitor = [
    ", preferred, auto-left, 1"
  ];
}
