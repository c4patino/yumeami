{self, ...}: {
  home = {
    username = "c4patino";
    homeDirectory = "/home/c4patino";
    stateVersion = "23.11";
    sessionVariables = {
      FLAKE = "/home/c4patino/dotfiles";
    };

    file = {
      ".ssh/id_ed25519".source = "${self}/secrets/crypt/ssh/chibi/id_ed25519";
      ".ssh/id_ed25519.pub".source = "${self}/secrets/crypt/ssh/chibi/id_ed25519.pub";
      ".config/sops/age/keys.txt".source = "${self}/secrets/crypt/age/chibi/keys.txt";
    };
  };

  ssh.enable = true;
  zoxide.enable = true;
  zsh.enable = true;
  languages.enable = true;
  git.enable = true;
  lazygit.enable = true;
  hyperfine.enable = true;

  bottom.enable = true;
  yazi.enable = true;

  lastpass.enable = true;

  neovim.enable = true;
}
