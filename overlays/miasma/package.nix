{
  lib,
  fetchFromGitHub,
  rustPlatform,
  cacert,
}:
rustPlatform.buildRustPackage rec {
  pname = "miasma";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "austin-weeks";
    repo = "miasma";
    tag = "v${version}";
    hash = "sha256-QaFVg+1rI6C0fh6Iq3SHcJ30JoVGBQ8g90K1gfNBThs=";
  };

  cargoHash = "sha256-pE6wKCfDAIBlrhhl7PUbcokg3KvnW8urZ9yk9qe8miI=";

  buildInputs = [cacert];

  meta = {
    description = "Trap AI web scrapers in an endless poison pit";
    homepage = "https://github.com/austin-weeks/miasma";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
  };
}
