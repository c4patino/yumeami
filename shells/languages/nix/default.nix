{
  pkgs,
  mkShell,
  ...
}:
mkShell {
  packages = with pkgs; [
    alejandra
    nix-prefetch-scripts
  ];

  shellHook = ''
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NIX_LD_LIBRARY_PATH;
  '';
}
