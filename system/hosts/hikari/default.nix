{ pkgs, modulesPath, inputs, ... }: {
    imports = [
        "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"

        inputs.home-manager.nixosModules.home-manager

        ../..
    ];

    environment.systemPackages = with pkgs; [
        neovim
        disko
        parted
        git
    ];

    efi-bootloader.enable = false;
    audio.enable = false;
    network-manager.enable = false;
    hyprland.enable = false;

    nixpkgs.hostPlatform = "x86_64-linux";
}
