{channels, ...}: final: prev: {
  inherit
    (channels.nixpkgs-unstable)
    gh-stack
    immich
    lazygit
    presenterm
    tuicr
    vaultwarden
    ;
}
