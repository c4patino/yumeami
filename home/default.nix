{ pkgs, ... }: {
    programs.home-manager.enable = true;

    nixpkgs.config.allowUnfree = true;

    home.packages = [
        (import ./scripts/get-music-cover.nix { inherit pkgs; })
        (import ./scripts/scratchpad.nix { inherit pkgs; })
    ];
}
