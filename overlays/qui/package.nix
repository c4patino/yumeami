{
  lib,
  fetchzip,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation rec {
  pname = "qui";
  version = "1.36.1";

  src =
    {
      x86_64-linux = fetchzip {
        url = "https://github.com/autobrr/qui/releases/download/v${version}/qui_${version}_linux_x86_64.tar.gz";
        hash = "sha256-4pZ+HhoxSu6HuoehAWxMEzndCit0wYNoA/PKyTrVV/4=";
        stripRoot = false;
      };
      aarch64-linux = fetchzip {
        url = "https://github.com/autobrr/qui/releases/download/v${version}/qui_${version}_linux_arm64.tar.gz";
        hash = "sha256-zDxjbhptrhXaHCc8sSFrv6f3warj11R9W8gSWmEB0VM=";
        stripRoot = false;
      };
      x86_64-darwin = fetchzip {
        url = "https://github.com/autobrr/qui/releases/download/v${version}/qui_${version}_darwin_x86_64.tar.gz";
        hash = "sha256-/ZvuLuWpZywm82yDOC6hobCzc85nsrmKHxGK+WP+C0Q=";
        stripRoot = false;
      };
      aarch64-darwin = fetchzip {
        url = "https://github.com/autobrr/qui/releases/download/v${version}/qui_${version}_darwin_arm64.tar.gz";
        hash = "sha256-01fwVKwg6Qvae/ugrsWOwkZpw++NdlgWSwK+ssYmjVc=";
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
