{...}: {
  imports = [
    ./filesystems
    ./glance

    ./github-runner.nix
    ./ntfy.nix
    ./pm2.nix
    ./rustypaste.nix
    ./slurm.nix
    ./tailscale.nix
    ./uptime-kuma.nix
  ];
}
