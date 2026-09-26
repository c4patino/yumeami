{
  lib,
  fetchFromGitHub,
  rustPlatform,
  cacert,
  pkg-config,
  sqlite,
}:
rustPlatform.buildRustPackage rec {
  pname = "miasma";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "austin-weeks";
    repo = "miasma";
    tag = "v${version}";
    hash = "sha256-Jv0nKOdynhRiWcMX9uh1BZYmRJ1c9PXWxPr+yDq7XvQ=";
  };

  cargoHash = "sha256-PddTPwQNrLn64CJkPxSsk8N/JVA2Kw7VFCzGt36Virk=";

  doCheck = false;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    cacert
    sqlite
  ];

  meta = {
    description = "Trap AI web scrapers in an endless poison pit";
    homepage = "https://github.com/austin-weeks/miasma";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [
      c4patino
    ];
  };
}
