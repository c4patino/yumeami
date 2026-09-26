{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  makeWrapper,
  nodejs,
  obsidian,
  asar,
}:
buildNpmPackage rec {
  pname = "ignis";
  version = "0.8.13";

  src = fetchFromGitHub {
    owner = "Nystik-gh";
    repo = "ignis";
    rev = "v${version}+obsidian.1.13.7";
    hash = "sha256-goNBISE0mla3NTTMgUfLpDxsqo9P96M3e9yQNoy9jfA=";
  };

  npmDepsHash = "sha256-TsYwSSLZPfOLcV2QjgyfoqMUvJAbM2RCDxK1We656eA=";
  npmDepsFetcherVersion = 2;

  nativeBuildInputs = [
    makeWrapper
    asar
    obsidian
  ];

  installPhase = ''
    runHook preInstall

    npm prune --omit=dev --ignore-scripts

    mkdir -p $out/lib/ignis
    cp -r . $out/lib/ignis/

    mkdir -p $out/lib/ignis/obsidian-app
    ${lib.getExe asar} extract ${obsidian}/share/obsidian/obsidian.asar $out/lib/ignis/obsidian-app

    mkdir -p $out/bin
    makeWrapper ${lib.getExe nodejs} $out/bin/ignis-server \
      --add-flags "$out/lib/ignis/apps/ignis-server/server/index.js" \
      --chdir "$out/lib/ignis"

    runHook postInstall
  '';

  meta = {
    description = "Run Obsidian as a self-hosted web app";
    homepage = "https://github.com/Nystik-gh/ignis";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [
      c4patino
    ];
  };
}
