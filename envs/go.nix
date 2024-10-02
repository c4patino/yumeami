{
	pkgs ? import <nixpkgs> { config = { allowUnfree = true; cudaSupport = true; }; }
}: pkgs.mkShell {
    name = "go-dev";

	nativeBuildInputs = with pkgs; [
		go
		gotools
		golangci-lint
	];

    shell = pkgs.zsh;

    shellHook = ''
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NIX_LD_LIBRARY_PATH;
    '';
}
