{...}: {
  imports = [
    ./filesystems

    ./github-runner.nix
    ./ntfy.nix
    ./pm2.nix
    ./slurm.nix
    ./tailscale.nix
  ];
}
