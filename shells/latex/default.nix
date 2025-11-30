{
  pkgs,
  mkShell,
}:
mkShell {
  nativeBuildInputs = with pkgs; [
    texliveFull
  ];
}
