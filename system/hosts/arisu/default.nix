{ pkgs, inputs, ... }:
{
    imports = [
        ../..
        ./hardware-configuration.nix

        inputs.disko.nixosModules.default
        (import ./disko.nix { device = "/dev/nvme0n1"; })
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

	audio.enable = true;
	efi-bootloader.enable = true;
	network-manager.enable = true;
    nvidia.enable = true;

	docker.enable = true;
    slurm.enable = true;
    virtualbox.enable = true;
    teamviewer.enable = true;

    github-runners.enable = true;
	tailscale.enable = true;

	hyprland.enable = true;
	steam.enable = true;
}
