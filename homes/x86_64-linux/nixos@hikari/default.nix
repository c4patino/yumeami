{
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib.${namespace}) enabled;
in {
  ${namespace}.cli = {
    access.ssh = enabled;

    dev = {
      git = enabled;
      lazygit = enabled;

      neovim = {
        enable = true;
        variant = "minimal";
      };

      zoxide = enabled;
      zsh = enabled;
    };

    media.yazi = enabled;
    metrics.btm = enabled;
  };

  home = {
    packages = with pkgs; [
      curl
      wget
      zip
      unzip
    ];

    file."dotfiles".source = inputs.self;
    sessionVariables.NH_FLAKE = "/home/nixos/dotfiles";
    stateVersion = "26.05";
  };

  programs.git.settings.safe.directory = ["~/dotfiles"];
}
