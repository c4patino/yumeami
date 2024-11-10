{pkgs, ...}: {
  imports = [
    ./filesystems.nix
    ./locales.nix
    ./security.nix
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    home-manager

    nh
    nix-output-monitor
    nvd
  ];

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      cudaPackages.cudatoolkit
    ];
  };

  programs.zsh.enable = true;

  system.stateVersion = "24.05";
}
