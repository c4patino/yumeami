{
  lib,
  fetchFromGitHub,
  python3,
  makeWrapper,
  seafile-server,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "seahub";
  version = "13.0.25";
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
    django
    django-compressor
    django-statici18n
    django-webpack-loader
    django-simple-captcha
    django-picklefield
    django-formtools
    djangosaml2
    mysqlclient
    pillow
    python-dateutil
    djangorestframework
    openpyxl
    requests
    requests-oauthlib
    chardet
    pyjwt
    pycryptodome
    pyopenssl
    python-ldap
    qrcode
    pysearpc
    gunicorn
    markdown
    bleach
    sqlalchemy
    pymysql
    (python3.pkgs.toPythonModule (seafile-server.override {inherit python3;}))
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
  '';

  passthru = {
    inherit python3;
    pythonPath = python3.pkgs.makePythonPath propagatedBuildInputs;
    inherit seafile-server;
  };

  meta = {
    description = "Web end of seafile server";
    homepage = "https://github.com/haiwen/seahub";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
  };
}
