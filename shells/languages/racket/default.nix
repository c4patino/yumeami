{
  pkgs,
  mkShell,
  ...
}:
mkShell {
  nativeBuildInputs = with pkgs; [
    racket
  ];

  shellHook = ''
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NIX_LD_LIBRARY_PATH;
  '';
}
