{channels, ...}: final: prev: {
  inherit
    (channels.nixpkgs-unstable)
    gh-stack
    opencode
    presenterm
    tuicr
    vaultwarden
    ;
}
