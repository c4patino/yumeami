{ config, pkgs, inputs, ... }:
{
    imports = [
        ../../nixosModules
        ./hardware-configuration.nix

        inputs.disko.nixosModules.default
        (import ./disko.nix { device = "/dev/nvme0n1"; })
    ];

    networking.hostName = "kokoro";
    networking.networkmanager.enable = true;
    
    users.users.c4patino = {
        isNormalUser = true;
        description = "C4 Patino";
        extraGroups = [ "networkmanager" "wheel" "vboxusers" "docker" ];
        initialPassword = "passw0rd";
        shell = pkgs.zsh;
    };

    docker.enable = true;
    virtualbox.enable = true;
    teamviewer.enable = true;
    xremap.enable = true;
}
