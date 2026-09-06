# TODO: remove this overlay once nixpkgs-unstable has autobrr >= 1.85.0
# and the stable channel catches up. Until then, we vendor the upstream
# package.nix at 1.85.0 and override buildGoModule to use Go 1.27 from
# unstable (stable only has 1.27rc3 which doesn't satisfy go.mod).
# https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/au/autobrr/package.nix
{channels, ...}: final: prev: {
  autobrr = final.callPackage ./package.nix {
    buildGoModule = prev.buildGoModule.override {
      go = channels.nixpkgs-unstable.go_1_27;
    };
  };
}
