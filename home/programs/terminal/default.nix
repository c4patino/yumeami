{ lib, ... }: {
    imports = [
        ./bat.nix
        ./git.nix
        ./kitty.nix
        ./leetcode.nix
        ./metrics.nix
        ./ssh.nix
        ./zoxide.nix
        ./zsh.nix
    ];
}
