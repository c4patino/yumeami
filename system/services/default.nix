{...}: {
  imports = [
    ./glance
    ./networking
    ./storage

    ./github-runner.nix
    ./grafana.nix
    ./ntfy.nix
    ./pm2.nix
    ./slurm.nix
    ./uptime-kuma.nix
    ./vaultwarden.nix
  ];
}
