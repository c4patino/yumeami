{
  pkgs,
  mkShell,
}:
mkShell {
  nativeBuildInputs = with pkgs; [
    d2
    mermaid-cli
    pandoc
    python313Packages.weasyprint
    typst
  ];

  packages = with pkgs; [
    presenterm
  ];
}
