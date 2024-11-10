{pkgs, ...}:
pkgs.stdenv.mkDerivation {
  name = "gruvbox-plus";

  src = pkgs.fetchurl {
    url = "https://github.com/SylEleuth/gruvbox-plus-icon-pack/releases/download/v3.1/gruvbox-plus-icon-pack-3.1.zip";
    sha256 = "0rra07p0iw1k4ncp40ri7khw1xvysm0d4qvfn2bjf07zij2k7w4b";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out
    ${pkgs.unzip}/bin/unzip $src -d $out/
  '';
}
