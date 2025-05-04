{...}: {
  imports = [
    ./glance
    ./networking
    ./storage

    ./github-runner.nix
    ./ntfy.nix
    ./pm2.nix
    ./rustypaste.nix
    ./slurm.nix
    ./uptime-kuma.nix
  ];
}
