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
