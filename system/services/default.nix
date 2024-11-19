{...}: {
  imports = [
    ./github-runner.nix
    ./pm2.nix
    ./slurm.nix
    ./syncthing.nix
    ./tailscale.nix
  ];
}
