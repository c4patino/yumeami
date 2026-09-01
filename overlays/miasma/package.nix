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
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "austin-weeks";
    repo = "miasma";
    tag = "v${version}";
    hash = "sha256-hmbYiOcjMECrh4Uuy22D8eCwcY7BPbme0NlUEoCtEv0=";
  };

  cargoHash = "sha256-mufs5AETj6XRNgsPXYlugo+FxCJIomsJcOd/dJs5RLo=";

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
