# NOTE: This overlay can be removed when PR #585017 is merged and available
# in the stable channel. The PR adds pkg-config and oniguruma to tuicr
# natively, making this override unnecessary.
{channels, ...}: final: prev: {
  tuicr = channels.nixpkgs-unstable.tuicr.overrideAttrs (oldAttrs: {
    nativeBuildInputs =
      (oldAttrs.nativeBuildInputs or [])
      ++ [
        channels.nixpkgs-unstable.pkg-config
      ];
    buildInputs =
      (oldAttrs.buildInputs or [])
      ++ [
        channels.nixpkgs-unstable.libgit2
        channels.nixpkgs-unstable.oniguruma
      ];
  });
}
