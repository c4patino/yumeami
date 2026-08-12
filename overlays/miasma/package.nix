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
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "austin-weeks";
    repo = "miasma";
    tag = "v${version}";
    hash = "sha256-ng2/p/c22oNSySkemeq2Imd2s3fHtlP2cAX8XKyurjs=";
  };

  cargoHash = "sha256-BUUP8TSjk6YIbh7nGA+5PY4TG00Ua0bRQ705e1sMjZ0=";

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
