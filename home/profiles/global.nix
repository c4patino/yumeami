{
  self,
  pkgs,
  hostName,
  config,
  lib,
  ...
}: {
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  home = {
    username = "c4patino";
    homeDirectory = "/home/c4patino";
    stateVersion = "23.11";
    sessionVariables = {
      NH_FLAKE = "${config.home.homeDirectory}/dotfiles";
    };

    packages = with pkgs; [
      curl
      wget
      unzip
      xclip
      sops
      git-crypt
    ];

    file = let
      crypt = "${self}/secrets/crypt/";
    in {
      ".ssh/id_ed25519".source = "${crypt}/ssh/${hostName}/id_ed25519";
      ".ssh/id_ed25519.pub".source = "${crypt}/ssh/${hostName}/id_ed25519.pub";
      ".config/sops/age/keys.txt".source = "${crypt}/age/${hostName}/keys.txt";
      ".config/rustypaste/config.toml".source = "${crypt}/rustypaste/client.toml";
    };

    activation.createDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p ~/Downloads
      chmod 755 ~/Downloads
    '';
  };

  neovim.enable = true;

  yazi.enable = true;

  git.enable = true;
  hyperfine.enable = true;
  lastpass.enable = true;
  lazygit.enable = true;
  bottom.enable = true;
  ssh.enable = true;
  zsh.enable = true;
  zoxide.enable = true;

  languages.enable = true;
}
