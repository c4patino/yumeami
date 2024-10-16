{
	pkgs ? import <nixpkgs> { config = { allowUnfree = true; cudaSupport = true; }; }
}: pkgs.mkShell {
    name = "rust-dev";

    nativeBuildInputs = with pkgs; [
		cargo
		rustc
		rustfmt
    ];

    shell = pkgs.zsh;

    shellHook = ''
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NIX_LD_LIBRARY_PATH;
    '';
}
