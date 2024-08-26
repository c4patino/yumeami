{ pkgs ? import <nixpkgs> { 
    config = {
        allowUnfree = true;
        cudaSupport = true;
    };
}}: pkgs.mkShell {
    name = "python312-dev";

    nativeBuildInputs = with pkgs; [
        poetry

        python312
        python312Packages.virtualenv
    ];

    shell = pkgs.zsh;

    shellHook = ''
        export LD_LIBRARY_PATH=${pkgs.linuxPackages.nvidia_x11}/lib:
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NIX_LD_LIBRARY_PATH;
    '';
}
