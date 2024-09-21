{ pkgs, inputs, ... }:
{
    imports = [
        ../..

		inputs.nixos-hardware.nixosModules.raspberry-pi-4
		../hardware-configuration.nix

        inputs.disko.nixosModules.default
        (import ./disko.nix { device = ""; })
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

	audio.enable = true;
	network-manager.enable = true;

	docker.enable = true;

    github-runners.enable = true;
	tailscale.enable = true;
}
