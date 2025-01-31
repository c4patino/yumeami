{
  pkgs,
  config,
  ...
}: {
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
    libraries = with pkgs;
      [
        stdenv.cc.cc
      ]
      ++ lib.optionals config.nvidia.enable [
        cudaPackages.cudatoolkit
      ];
  };

  programs.zsh.enable = true;

  system.stateVersion = "24.11";
}
