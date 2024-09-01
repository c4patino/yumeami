{ ... }: {
    imports = [
        ./docker.nix
        ./github-runner.nix
        ./slurm.nix
        ./virtualbox.nix
        ./teamviewer.nix
    ];
}
