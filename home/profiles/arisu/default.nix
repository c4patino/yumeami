{self, ...}: {
  imports = [
    ./stylix.nix
  ];

  home = {
    username = "c4patino";
    homeDirectory = "/home/c4patino";
    stateVersion = "23.11";
    sessionVariables = {
      FLAKE = "/home/c4patino/dotfiles";
    };

    file = {
      ".ssh/id_ed25519".source = "${self}/secrets/crypt/ssh/arisu/id_ed25519";
      ".ssh/id_ed25519.pub".source = "${self}/secrets/crypt/ssh/arisu/id_ed25519.pub";
      ".config/sops/age/keys.txt".source = "${self}/secrets/crypt/age/arisu/keys.txt";
    };
  };

  hyprland.enable = true;
  kitty.enable = true;
  anyrun.enable = true;

  ssh.enable = true;
  zoxide.enable = true;
  zsh.enable = true;
  languages.enable = true;
  git.enable = true;
  lazygit.enable = true;
  hyperfine.enable = true;

  bottom.enable = true;
  nvtop.enable = true;
  yazi.enable = true;

  music.enable = true;
  leetcode.enable = true;

  lastpass.enable = true;

  android-studio.enable = true;
  neovim.enable = true;
  pycharm.enable = true;
  idea.enable = true;

  browsers.enable = true;
  fiji.enable = true;
  libreoffice.enable = true;
  obs.enable = true;
  obsidian.enable = true;
  postman.enable = true;
  sms.enable = true;

  prismlauncher.enable = true;

  wayland.windowManager.hyprland.settings.monitor = [
    "DP-1, 2560x1440@120, 0x0, 1"
    "DP-2, 2560x1440@120, 2560x0, 1"
    ", preferred, auto, 1"
  ];
}
