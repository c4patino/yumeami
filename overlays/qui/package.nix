{
  lib,
  fetchzip,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation rec {
  pname = "qui";
  version = "1.36.0";

  src =
    {
      x86_64-linux = fetchzip {
        url = "https://github.com/autobrr/qui/releases/download/v${version}/qui_${version}_linux_x86_64.tar.gz";
        hash = "sha256-BFWl95rLu74yVLnw1gbDW9fyrIGSZlMl+r1s+lYct8E=";
        stripRoot = false;
      };
      aarch64-linux = fetchzip {
        url = "https://github.com/autobrr/qui/releases/download/v${version}/qui_${version}_linux_arm64.tar.gz";
        hash = "sha256-Oy3swCWUkF2pubb5HZv65xJkBHwWj7yMYO6TWIU8TZ8=";
        stripRoot = false;
      };
      x86_64-darwin = fetchzip {
        url = "https://github.com/autobrr/qui/releases/download/v${version}/qui_${version}_darwin_x86_64.tar.gz";
        hash = "sha256-DpayEoC+ysEYGCB3Ze8h4B69lGGORYtTPpcN6NWrF14=";
        stripRoot = false;
      };
      aarch64-darwin = fetchzip {
        url = "https://github.com/autobrr/qui/releases/download/v${version}/qui_${version}_darwin_arm64.tar.gz";
        hash = "sha256-p+kHoa3AweDPurqj0flOPJ+j6wgMXgO/B1zLoDtEvJE=";
        stripRoot = false;
      };
    }.${
      stdenvNoCC.hostPlatform.system
    }
    or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");

  installPhase = ''
    runHook preInstall

    install -Dm755 qui $out/bin/qui
    install -Dm644 README.md $out/share/doc/qui/README.md
    install -Dm644 LICENSE $out/share/licenses/qui/LICENSE
    install -Dm644 THIRD_PARTY_NOTICES $out/share/licenses/qui/THIRD_PARTY_NOTICES

    runHook postInstall
  '';

  meta = {
    description = "Modern alternative webUI for qBittorrent, with multi-instance support";
    homepage = "https://github.com/autobrr/qui";
    changelog = "https://github.com/autobrr/qui/releases/tag/v${version}";
    license = lib.licenses.gpl2Plus;
    sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    mainProgram = "qui";
    platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    maintainers = with lib.maintainers; [
      c4patino
    ];
  };
}
