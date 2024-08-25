{ pkgs ? import <nixpkgs> { 
    config = {
        allowUnfree = true;
        cudaSupport = true;
    };
}}: pkgs.mkShell {
    name = "oasys";

    buildInputs = with pkgs; [
        python311
        python311Packages.virtualenv
        python311Packages.pip
        python311Packages.scipy
        python311Packages.torch
        python311Packages.cython

        git gitRepo gnupg autoconf curl
        procps gnumake util-linux m4 gperf unzip
        cudatoolkit linuxPackages.nvidia_x11
        libGLU libGL
        xorg.libXi xorg.libXmu freeglut
        xorg.libXext xorg.libX11 xorg.libXv xorg.libXrandr zlib 
        ncurses5 stdenv.cc binutils
    ];

    shell = pkgs.zsh;

    shellHook = ''
        export CUDA_PATH=${pkgs.cudaPackages.cudatoolkit}
        export LD_LIBRARY_PATH=${pkgs.linuxPackages.nvidia_x11}/lib:${pkgs.ncurses5}/lib
        export LD_LIBRARY_PATH=/run/opengl-drivers/lib:$LD_LIBRARY_PATH
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NIX_LD_LIBRARY_PATH;
        export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib"
        export EXTRA_CCFLAGS="-I/usr/include"
    '';
}
