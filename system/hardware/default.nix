{ ... }: {
    imports = [
        ./audio.nix
        ./battery.nix
        ./bootloader.nix
		./display-manager.nix
        ./network-manager.nix
        ./nvidia.nix
        ./xremap.nix
    ];
}
