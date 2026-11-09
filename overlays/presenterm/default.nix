# NOTE: This overlay can be removed when PR #584850 is merged and available
# in the stable channel. The PR adds pkg-config and oniguruma to presenterm
# natively, making this override unnecessary.
{channels, ...}: final: prev: {
  presenterm = channels.nixpkgs-unstable.presenterm.overrideAttrs (oldAttrs: {
    nativeBuildInputs =
      (oldAttrs.nativeBuildInputs or [])
      ++ [
        channels.nixpkgs-unstable.pkg-config
      ];
    buildInputs =
      (oldAttrs.buildInputs or [])
      ++ [
        channels.nixpkgs-unstable.oniguruma
      ];
  });
}
