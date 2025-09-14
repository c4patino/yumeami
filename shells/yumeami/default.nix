{
  pkgs,
  mkShell,
}:
mkShell {
  buildInputs = with pkgs; [
    lua
  ];

  packages = with pkgs; [
    alejandra
    nix-prefetch-scripts
    stylua
  ];
}
