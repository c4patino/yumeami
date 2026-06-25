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
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "austin-weeks";
    repo = "miasma";
    tag = "v${version}";
    hash = "sha256-cr3p1fFxt2HLPyfzXH/4J6YLWsC4WxCfFvcNjV29BzI=";
  };

  cargoHash = "sha256-DFp1+9QyBrgIeysXk8qBnRwD/eCPiHunEEKk1uYvXxw=";

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
  };
}
