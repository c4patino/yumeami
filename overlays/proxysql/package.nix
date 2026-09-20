{
  stdenv,
  lib,
  fetchFromGitHub,
  autoconf,
  automake,
  bison,
  cmake,
  pkg-config,
  libtool,
  coreutils,
  flex,
  gnutls,
  icu,
  libevent,
  libgcrypt,
  libuuid,
  openssl,
  perl,
  python3,
  texinfo,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "proxysql";
  version = "3.0.11";

  src = fetchFromGitHub {
    owner = "sysown";
    repo = "proxysql";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6cSy8Tw9CLhX7t0dNQWDZiNjstWWETw1qVsNq/9JhoY=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    cmake
    libtool
    perl
    pkg-config
    python3
    texinfo
  ];

  buildInputs = [
    bison
    flex
    gnutls
    icu
    libevent
    libgcrypt
    libuuid
    openssl
    zlib
  ];

  enableParallelBuilding = true;

  env = {
    SOURCE_DATE_EPOCH = "1787757180";
  };

  dontConfigure = true;

  makeFlags = ["GIT_VERSION_BASE=v${finalAttrs.version}"];

  preBuild = ''
    patchShebangs .

    updateArchive() {
      local directory="$1"
      local archive="$2"
      shift 2

      pushd "$directory"
      tar xf "$archive"

      "$@"
      patchShebangs */

      rm "$archive"
      tar czf "$archive" */

      rm -rf */
      popd
    }

    updateArchive deps/curl curl-8.16.0.tar.gz true
    updateArchive deps/libhttpserver libhttpserver-0.18.2.tar.gz \
      substituteInPlace libhttpserver-0.18.2/configure.ac --replace-fail /bin/pwd ${coreutils}/bin/pwd
    updateArchive deps/libinjection libinjection-3.10.0.tar.gz \
      patch -d libinjection-3.10.0 -p1 --batch -i ../update-build-py3.diff

    substituteInPlace deps/Makefile \
      --replace-fail 'cd libinjection/libinjection && patch -p1 < ../update-build-py3.diff' \
        ':' \
      --replace-fail --enable-shared=yes --enable-shared=yes\ --disable-docs
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 src/proxysql $out/bin/proxysql
    install -Dm600 etc/proxysql.cnf $out/etc/proxysql.cnf
    install -Dm644 systemd/system/proxysql.service $out/lib/systemd/system/proxysql.service
    substituteInPlace $out/lib/systemd/system/proxysql.service \
      --replace-fail /usr/bin/proxysql $out/bin/proxysql

    runHook postInstall
  '';

  meta = {
    broken = stdenv.hostPlatform.isDarwin;
    description = "High-performance MySQL and PostgreSQL proxy";
    mainProgram = "proxysql";
    homepage = "https://proxysql.com/";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.unix;
  };
})
