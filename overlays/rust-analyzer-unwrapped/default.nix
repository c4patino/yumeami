# HACK: this should not be necessary, temporary patch until merge (https://github.com/NixOS/nixpkgs/pull/433196)
{...}: final: prev: {
  rust-analyzer-unwrapped = prev.rust-analyzer-unwrapped.overrideAttrs (oldAttrs: {
    version = "2025-08-11";
    src = final.fetchFromGitHub {
      owner = "rust-lang";
      repo = "rust-analyzer";
      rev = "2025-08-11";
      hash = "sha256-fuHLsvM5z5/5ia3yL0/mr472wXnxSrtXECa+pspQchA=";
    };
  });
}
