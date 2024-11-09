{
	pkgs ? import <nixpkgs> { config = { allowUnfree = true; cudaSupport = true; }; }
}: pkgs.mkShell {
    name = "nix-dev";

    nativeBuildInputs = with pkgs; [
		alejandra
    ];

    shell = pkgs.zsh;

    shellHook = ''
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NIX_LD_LIBRARY_PATH;
    '';
}
