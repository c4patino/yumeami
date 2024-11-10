{...}: {
  home = {
    username = "c4patino";
    homeDirectory = "/home/c4patino";
    stateVersion = "23.11";
    sessionVariables = {
      FLAKE = "/home/c4patino/dotfiles";
    };
  };

  ssh.enable = true;
  zoxide.enable = true;
  zsh.enable = true;
  languages.enable = true;
  git.enable = true;
  lazygit.enable = true;

  bottom.enable = true;
  yazi.enable = true;

  lastpass.enable = true;

  neovim.enable = true;
}
