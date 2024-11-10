{
  pkgs,
  inputs,
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

  home.packages = with pkgs; [
    curl
    wget
    unzip
    xclip
    sops
    git-crypt
  ];
}
