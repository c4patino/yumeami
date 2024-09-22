{ pkgs, inputs, modulesPath, ... }:
{
    imports = [
        ../..

        "${modulesPath}/installer/sd-card/sd-image-raspberrypi-installer.nix"

		inputs.nixos-hardware.nixosModules.raspberry-pi-4
		./hardware-configuration.nix
    ];

    networking.hostName = "chibi";
    networking.networkmanager.enable = true;

    users.users.c4patino = {
        isNormalUser = true;
        description = "C4 Patino";
        extraGroups = [ "networkmanager" "wheel" "vboxusers" "docker" ];
        initialPassword = "passw0rd";
        shell = pkgs.zsh;
    };

	network-manager.enable = true;

	docker.enable = true;

    github-runners.enable = true;
	tailscale.enable = true;
}
