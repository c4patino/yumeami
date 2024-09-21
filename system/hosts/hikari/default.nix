{ pkgs, modulesPath, inputs, ... }: {
    imports = [
        "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"

        inputs.home-manager.nixosModules.home-manager

        ../..
    ];

    environment.systemPackages = with pkgs; [
        disko
        parted
        git
    ];

    nixpkgs.hostPlatform = "x86_64-linux";
}
