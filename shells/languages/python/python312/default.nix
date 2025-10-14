{
  pkgs,
  mkShell,
  ...
}:
mkShell {
  buildInputs = with pkgs; [
    poetry
    python312
    python312Packages.virtualenv
  ];

  packages = with pkgs; [
    python312Packages.debugpy
    yapf
  ];

  shellHook = ''
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.libGL}/lib
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.glib.out}/lib
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.stdenv.cc.cc.lib}/lib
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/run/opengl-driver/lib
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NIX_LD_LIBRARY_PATH
  '';
}
