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

  packages = [
    (
      # NOTE: This override can be removed when PR #584850 is merged and available
      # in the stable channel. The PR adds pkg-config and oniguruma to presenterm
      # natively, making this override unnecessary.
      pkgs.presenterm.overrideAttrs (oldAttrs: {
        nativeBuildInputs =
          (oldAttrs.nativeBuildInputs or [])
          ++ [
            pkgs.pkg-config
          ];
        buildInputs = (oldAttrs.buildInputs or []) ++ [pkgs.oniguruma];
      })
    )
    (
      # NOTE: This override can be removed when PR #585017 is merged and available
      # in the stable channel. The PR adds pkg-config and oniguruma to tuicr
      # natively, making this override unnecessary.
      pkgs.tuicr.overrideAttrs (oldAttrs: {
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [pkgs.pkg-config];
        buildInputs = (oldAttrs.buildInputs or []) ++ [pkgs.oniguruma];
      })
    )
  ];
}
