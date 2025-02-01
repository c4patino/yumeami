{
  self,
  pkgs,
  inputs,
  hostName,
  config,
  ...
}: {
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  imports = [
    ./programs
    ./wayland
    ./scripts

    inputs.sops-nix.homeManagerModules.sops
  ];

  home = {
    username = "c4patino";
    homeDirectory = "/home/c4patino";
    stateVersion = "23.11";
    sessionVariables = {
      FLAKE = "${config.home.homeDirectory}/dotfiles";
    };

    packages = with pkgs; [
      curl
      wget
      unzip
      xclip
      sops
      git-crypt
    ];

    file = {
      ".ssh/id_ed25519".source = "${self}/secrets/crypt/${hostName}/id_ed25519";
      ".ssh/id_ed25519.pub".source = "${self}/secrets/crypt/${hostName}/id_ed25519.pub";
      ".config/sops/age/keys.txt".source = "${self}/secrets/crypt/${hostName}/keys.txt";
    };
  };

  ssh.enable = true;
  zsh.enable = true;

  languages.enable = true;
  git.enable = true;
  lazygit.enable = true;
  neovim.enable = true;

  bottom.enable = true;
  yazi.enable = true;
  zoxide.enable = true;
  hyperfine.enable = true;
  lastpass.enable = true;
}
