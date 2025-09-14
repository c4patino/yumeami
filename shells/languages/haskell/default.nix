{
  pkgs,
  mkShell,
  ...
}:
mkShell {
  nativeBuildInputs = with pkgs; [
    ghc
    stack
  ];

  packages = with pkgs; [
    cabal-install
    haskellPackages.haskell-debug-adapter
    ormolu
  ];

  shellHook = ''
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NIX_LD_LIBRARY_PATH;
  '';
}
