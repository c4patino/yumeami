{ config, pkgs, inputs, ... }:
{
    imports = [
        ./hardware-configuration.nix
        ../../nixosModules
    ];

    networking.hostName = "arisu";
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
    nvidia.enable = true;
}
