{
  pkgs ?
    import <nixpkgs> {
      config = {
        allowUnfree = true;
        cudaSupport = true;
      };
    },
}:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    poetry

    python311Full
    python311Packages.virtualenv
    python311Packages.debugpy
  ];

  shell = pkgs.zsh;

  shellHook = ''
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.libGL}/lib
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.glib.out}/lib
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.stdenv.cc.cc.lib}/lib
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/run/opengl-driver/lib
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NIX_LD_LIBRARY_PATH
  '';
}
