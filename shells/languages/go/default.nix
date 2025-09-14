{
  pkgs,
  mkShell,
  ...
}:
mkShell {
  nativeBuildInputs = with pkgs; [
    go
  ];

  packages = with pkgs; [
    delve
    golangci-lint
    gotools
  ];

  hardeningDisable = ["fortify"];

  shellHook = ''
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NIX_LD_LIBRARY_PATH;
  '';
}
