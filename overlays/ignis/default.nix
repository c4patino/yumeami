{...}: final: prev: let
  # NOTE: ignis 0.8.9's shim is built against Obsidian 1.12.7 and hangs on
  # startup IPC channels introduced in 1.13.x. Keep the system `obsidian`
  # package at the latest and only override the copy ignis uses.
  srcs = {
    x86_64-linux = final.fetchurl {
      url = "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.14.4/obsidian-1.14.4.tar.gz";
      hash = "sha256-5wt81jeH5/eYqE/sRT9cRGuRh3vT9hLo+5jpt2zIESA=";
    };
    aarch64-linux = final.fetchurl {
      url = "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.14.4/obsidian-1.14.4-arm64.tar.gz";
      hash = "sha256-/CEoBFFXE+2F/l71vEsAmHK8wBhHxL5PzBSXHe7ipC0=";
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
