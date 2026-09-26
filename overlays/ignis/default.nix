{...}: final: prev: let
  # NOTE: ignis 0.8.9's shim is built against Obsidian 1.12.7 and hangs on
  # startup IPC channels introduced in 1.13.x. Keep the system `obsidian`
  # package at the latest and only override the copy ignis uses.
  srcs = {
    x86_64-linux = final.fetchurl {
      url = "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.13.7/obsidian-1.13.7.tar.gz";
      hash = "sha256-08vjdcv6QCTbGRC5gZFkn0E0xcSK7l5gtudxOYfc2yg=";
    };
    aarch64-linux = final.fetchurl {
      url = "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.13.7/obsidian-1.13.7-arm64.tar.gz";
      hash = "sha256-mKrDTR8TKjXPUG/D+hltWV3N7v3r1EsMxfqqehohDeI=";
    };
  };
in {
  ignis = final.callPackage ./package.nix {
    obsidian = prev.obsidian.overrideAttrs (old: {
      version = "1.13.7";
      src = srcs.${prev.stdenv.hostPlatform.system};
    });
  };
}
