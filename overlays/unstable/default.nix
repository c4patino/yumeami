{channels, ...}: final: prev: {
  inherit
    (channels.nixpkgs-unstable)
    gh-stack
    immich
    lazygit
    opencode
    presenterm
    tuicr
    vaultwarden
    ;
}
