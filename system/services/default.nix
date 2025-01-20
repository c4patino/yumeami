{...}: {
  imports = [
    ./github-runner.nix
    ./pm2.nix
    ./samba.nix
    ./slurm.nix
    ./syncthing.nix
    ./tailscale.nix
  ];
}
