{ ... }: {
    imports = [
        ./audio.nix
        ./battery.nix
        ./bootloader.nix
        ./network-manager.nix
        ./nvidia.nix
        ./xremap.nix
    ];
}
