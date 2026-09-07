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
  runCommand,
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
      libsearpc
      pkg-config
      python3
      vala
      which
    ];

    buildInputs = [
      curl
      fuse
      glib
      hiredis
      libarchive
      libargon2
      libevent
      libevhtp
      libjwt
      libmysqlclient
      libsearpc
      libuuid
      oniguruma
      python3
      sqlite
    ];

    postInstall = ''
      mkdir -p $out/share/seafile/sql
      cp -r scripts/sql $out/share/seafile
    '';

    # Generate the ccnet/seafile conf dir pointing at a given MySQL endpoint,
    # with the fileserver bound on its own public port (`host` is used verbatim
    # as the bind address by http-server.c; 0.0.0.0 is upstream's default).
    passthru.mkConf = {
      host,
      port,
      fileServerPort,
    }:
      runCommand "seafile-conf" {} ''
        mkdir -p $out
        cat > $out/ccnet.conf << EOF
        [Database]
        ENGINE = mysql
        HOST = ${host}
        PORT = ${toString port}
        DB = seafile-ccnet
        CONNECTION_CHARSET = utf8
        EOF

        cat > $out/seafile.conf << EOF
        [database]
        type = mysql
        host = ${host}
        port = ${toString port}
        db_name = seafile
        connection_charset = utf8

        [fileserver]
        port = ${toString fileServerPort}
        host = 0.0.0.0
        EOF
      '';

    meta = with lib; {
      description = "File syncing and sharing software with file encryption and group sharing";
      homepage = "https://github.com/haiwen/seafile-server";
      license = licenses.agpl3Plus;
      platforms = platforms.linux;
      mainProgram = "seaf-server";
    };
  }
