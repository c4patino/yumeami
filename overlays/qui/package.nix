{
  lib,
  fetchzip,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: rec {
  pname = "qui";
  version = "1.29.0";

  src = fetchzip {
    url = "https://github.com/autobrr/qui/releases/download/v${version}/qui_${version}_linux_x86_64.tar.gz";
    hash = "sha256-tP4mjXsHiddWoZalXh+w8x+E4TzboEW0HpsG7c1a2f4=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    install -Dm755 qui $out/bin/qui
    install -Dm644 README.md $out/share/doc/qui/README.md
    install -Dm644 LICENSE $out/share/licenses/qui/LICENSE

    runHook postInstall
  '';

  meta = {
    description = "Modern alternative webUI for qBittorrent, with multi-instance support";
    homepage = "https://github.com/autobrr/qui";
    changelog = "https://github.com/autobrr/qui/releases/tag/v${version}";
    license = lib.licenses.gpl2Plus;
    mainProgram = "qui";
    platforms = ["x86_64-linux"];
    maintainers = with lib.maintainers; [
      c4patino
    ];
  };
})
