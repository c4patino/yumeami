{ ... }: {
    imports = [
        ./audio.nix
        ./bootloader.nix
        ./network-manager.nix
        ./nvidia.nix
        ./xremap.nix
    ];
}
