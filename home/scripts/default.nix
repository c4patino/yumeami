{ pkgs, ... }: {
    home.packages = [
        (import ./get-music-cover.nix { inherit pkgs; })
        (import ./scratchpad.nix { inherit pkgs; })
    ];
}
