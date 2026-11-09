# NOTE: This overlay can be removed when a fix for adding aws-lc is added in
# the nixpkgs-unstable channel. There is no PR yet fixing this package.
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
