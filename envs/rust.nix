{
	pkgs ? import <nixpkgs> { config = { allowUnfree = true; cudaSupport = true; }; }, 
	enablePyTorch ? false,
}: pkgs.mkShell {
    name = "rust-dev";

    nativeBuildInputs = with pkgs; [
		cargo
		rustc
		rustfmt

		(if enablePyTorch then libtorch-bin else null)

		gdb
    ];

    shell = pkgs.zsh;

    shellHook = ''
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.libGL}/lib
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.glib.out}/lib
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/run/opengl-driver/lib
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NIX_LD_LIBRARY_PATH;
    '';
}
