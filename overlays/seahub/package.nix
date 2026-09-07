{
  lib,
  fetchFromGitHub,
  python3,
  makeWrapper,
  seafile-server,
  writeText,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "seahub";
  # Released in lockstep with seafile-server (same `v${version}-server` tag).
  inherit (seafile-server) version;
  pyproject = false;

  src = fetchFromGitHub {
    owner = "haiwen";
    repo = "seahub";
    rev = "v${version}-server";
    hash = "sha256-eTF3dhbqoEtknLVv4lG73EdhNdzdcE4WUBsdk9JdtRU=";
  };

  dontBuild = true;

  doCheck = false;

  nativeBuildInputs = [makeWrapper];

  propagatedBuildInputs = with python3.pkgs; [
    (python3.pkgs.toPythonModule (seafile-server.override {inherit python3;}))
    bleach
    chardet
    django
    django-compressor
    django-formtools
    django-picklefield
    django-simple-captcha
    django-statici18n
    django-webpack-loader
    djangorestframework
    djangosaml2
    gunicorn
    markdown
    mysqlclient
    openpyxl
    pillow
    pycryptodome
    pyjwt
    pymysql
    pyopenssl
    pysearpc
    python-dateutil
    python-ldap
    qrcode
    redis
    requests
    requests-oauthlib
    sqlalchemy
  ];

  postPatch = ''
    substituteInPlace seahub/settings.py --replace-fail "SEAFILE_VERSION = '6.3.3'" "SEAFILE_VERSION = '${version}'"
    substituteInPlace thirdpart/constance/management/commands/constance.py --replace-fail \
        "from __future__ import unicode_literals" ""
  '';

  installPhase = ''
    cp -dr --no-preserve='ownership' . $out/
    wrapProgram $out/manage.py \
      --prefix PYTHONPATH : "$PYTHONPATH:$out/thirdpart:"

    makeWrapper ${python3.pkgs.gunicorn}/bin/gunicorn $out/bin/seahub-wsgi \
      --prefix PYTHONPATH : "$PYTHONPATH:$out/thirdpart:$out" \
      --add-flags "seahub.wsgi:application"

    makeWrapper ${python3.interpreter} $out/bin/seahub-check-init-admin \
      --prefix PYTHONPATH : "$PYTHONPATH:$out/thirdpart:$out" \
      --add-flags "$out/scripts/check_init_admin.py"
  '';

  passthru = {
    inherit python3;
    pythonPath = python3.pkgs.makePythonPath propagatedBuildInputs;
    inherit seafile-server;

    # Generate seahub_settings.py for the given public endpoints (seahub on
    # `port`, seaf-server's fileserver on `fileServerPort`) and state root.
    mkSettings = {
      host,
      port,
      fileServerPort,
      seafRoot,
    }:
      writeText "seahub_settings.py" ''
        FILE_SERVER_ROOT = 'http://${host}:${toString fileServerPort}'
        MEDIA_ROOT = '${seafRoot}/seahub/media/'
        THUMBNAIL_ROOT = '${seafRoot}/seahub/thumbnail/'
        SERVICE_URL = 'http://${host}:${toString port}'
        CSRF_TRUSTED_ORIGINS = ["http://${host}:${toString port}"]
        TIME_ZONE = 'America/Chicago'

        with open('${seafRoot}/.seahubSecret') as f:
            SECRET_KEY = f.readline().rstrip()
      '';
  };

  meta = {
    description = "Web end of seafile server";
    homepage = "https://github.com/haiwen/seahub";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    mainProgram = "seahub-wsgi";
  };
}
