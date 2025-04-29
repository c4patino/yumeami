{...}: {
  imports = [
    ./stylix.nix
  ];

  home = {
    username = "nixos";
    homeDirectory = "/home/nixos";
    stateVersion = "23.11";
    sessionVariables = {
      NH_FLAKE = "/home/nixos/dotfiles";
    };
  };

  ssh.enable = true;
  zoxide.enable = true;
  zsh.enable = true;
  git.enable = true;
  lazygit.enable = true;

  bottom.enable = true;
  yazi.enable = true;

  neovim.enable = true;
}
