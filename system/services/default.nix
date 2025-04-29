{...}: {
  imports = [
    ./filesystems

    ./github-runner.nix
    ./pm2.nix
    ./slurm.nix
    ./tailscale.nix
  ];
}
