{pkgs, ...}: {
  imports = [
    ./core
    ./gaming
    ./hardware
    ./services
    ./virtualization
    ./hyprland.nix
    ./secrets.nix
  ];

  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;

    packages = with pkgs; [
      corefonts
      nerd-fonts.meslo-lg
      nerd-fonts.caskaydia-cove
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
    ];
  };
}
