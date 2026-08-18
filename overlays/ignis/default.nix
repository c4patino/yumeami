{...}: final: prev: let
  # NOTE: ignis 0.8.9's shim is built against Obsidian 1.12.7 and hangs on
  # startup IPC channels introduced in 1.13.x. Keep the system `obsidian`
  # package at the latest and only override the copy ignis uses.
  srcs = {
    x86_64-linux = final.fetchurl {
      url = "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.12.7/obsidian-1.12.7.tar.gz";
      hash = "sha256-/L4IsRHZwf2wm5wIlSsG4cgpxiFj66JYTEtOyFm+B50=";
    };
    aarch64-linux = final.fetchurl {
      url = "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.12.7/obsidian-1.12.7-arm64.tar.gz";
      hash = "sha256-a8hye/27bXMdWvmgb1HW3nBhxoyQjIrotDqe03miAmA=";
    };
  };
in {
  ignis = final.callPackage ./package.nix {
    obsidian = prev.obsidian.overrideAttrs (old: {
      version = "1.12.7";
      src = srcs.${prev.stdenv.hostPlatform.system};
    });
  };
}
