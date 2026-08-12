{channels, ...}: final: prev: {
  inherit
    (channels.nixpkgs-unstable)
    gh-stack
    lazygit
    opencode
    presenterm
    tuicr
    vaultwarden
    ;
}
