{
  lib,
  gcc13Stdenv,
  fetchFromGitHub,
  pkg-config,
  python3,
  autoreconfHook,
  libuuid,
  libmysqlclient,
  sqlite,
  glib,
  libevent,
  libsearpc,
  fuse,
  libarchive,
  libjwt,
  curl,
  hiredis,
  libargon2,
  which,
  vala,
  oniguruma,
  callPackage,
}: let
  version = "13.0.25";

  libevhtp = callPackage ./libevhtp.nix {};
in
  gcc13Stdenv.mkDerivation {
    pname = "seafile-server";
    inherit version;

    src = fetchFromGitHub {
      owner = "haiwen";
      repo = "seafile-server";
      rev = "v${version}-server";
      hash = "sha256-ZGXXcX3O/sZIVgR4BSMrqh+zwkK6Ei44M915w5w+HJw=";
    };

    nativeBuildInputs = [
      autoreconfHook
      pkg-config
      python3
      libsearpc
      vala
      which
    ];

    buildInputs = [
      libuuid
      libmysqlclient
      sqlite
      glib
      libsearpc
      libevent
      python3
      fuse
      libarchive
      libjwt
      libevhtp
      oniguruma
      curl
      hiredis
      libargon2
    ];

    postInstall = ''
      mkdir -p $out/share/seafile/sql
      cp -r scripts/sql $out/share/seafile
    '';

    meta = with lib; {
      description = "File syncing and sharing software with file encryption and group sharing";
      homepage = "https://github.com/haiwen/seafile-server";
      license = licenses.agpl3Plus;
      platforms = platforms.linux;
      mainProgram = "seaf-server";
    };
  }
