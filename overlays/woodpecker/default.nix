{...}: final: prev: {
  woodpecker-agent = prev.woodpecker-agent.overrideAttrs (old: rec {
    version = "3.11.0";

    src = final.fetchzip {
      url = "https://github.com/woodpecker-ci/woodpecker/releases/download/v${version}/woodpecker-src.tar.gz";
      hash = "sha256-mLyEHNMePVZI6MOSyeD9NMp9QXRXQ7h3LFSxHxpf878=";
      stripRoot = false;
    };
  });
  woodpecker-cli = prev.woodpecker-server.overrideAttrs (old: rec {
    version = "3.11.0";

    src = final.fetchzip {
      url = "https://github.com/woodpecker-ci/woodpecker/releases/download/v${version}/woodpecker-src.tar.gz";
      hash = "sha256-mLyEHNMePVZI6MOSyeD9NMp9QXRXQ7h3LFSxHxpf878=";
      stripRoot = false;
    };
  });
  woodpecker-server = prev.woodpecker-server.overrideAttrs (old: rec {
    version = "3.11.0";

    src = final.fetchzip {
      url = "https://github.com/woodpecker-ci/woodpecker/releases/download/v${version}/woodpecker-src.tar.gz";
      hash = "sha256-mLyEHNMePVZI6MOSyeD9NMp9QXRXQ7h3LFSxHxpf878=";
      stripRoot = false;
    };
  });
}
