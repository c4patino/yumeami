# NOTE: This overlay can be removed when PR #585833 is merged and available
# in the stable channel. The PR adds pkg-config and aws-lc to miasma
# natively, making this override unnecessary.
{channels, ...}: final: prev: {
  miasma = channels.nixpkgs-unstable.miasma.overrideAttrs (oldAttrs: {
    nativeBuildInputs =
      (oldAttrs.nativeBuildInputs or [])
      ++ [
        channels.nixpkgs-unstable.pkg-config
      ];
    buildInputs =
      (oldAttrs.buildInputs or [])
      ++ [
        channels.nixpkgs-unstable.aws-lc
      ];
  });
}
