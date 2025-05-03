{...}: {
  imports = [
    ./filesystems
    ./glance
    ./networking

    ./github-runner.nix
    ./ntfy.nix
    ./pm2.nix
    ./rustypaste.nix
    ./slurm.nix
    ./uptime-kuma.nix
  ];
}
