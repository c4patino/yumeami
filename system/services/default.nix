{ ... }: {
	imports = [
		./github-runner.nix
		./slurm.nix
		./syncthing.nix
		./tailscale.nix
	];
}

