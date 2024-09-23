{ pkgs, inputs, ... }:
{
    imports = [
        ../..
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

	boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

	audio.enable = true;
    battery.enable = true;
	efi-bootloader.enable = true;
	display-manager.enable = true;
	network-manager.enable = true;
    xremap.enable = true;

	tailscale.enable = true;

    docker.enable = true;
    virtualbox.enable = true;
    teamviewer.enable = true;

	hyprland.enable = true;
}
