{ pkgs ? import <nixpkgs> {} }: pkgs.stdenv.mkDerivation {
    name = "python311Packages.caiman";

    src = pkgs.fetchFromGitHub {
        owner = "flatironinstitute";
        repo = "CaImAn";
        rev = "bb55800806f0898592d79dcc705a0b53ccd01ec3";
        sha256 = "0x8kzv6w8rj6m94x8d43pzfzp5sr5vrs6y1nf84njpf0kyl4ka9x";
    };

    dontUnpack = true;

    installPhase = ''
        mkdir -p $out
        ${pkgs.unzip}/bin/unzip $src -d $out/



    '';

}




