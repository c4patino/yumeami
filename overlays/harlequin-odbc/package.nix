{
  lib,
  buildPythonPackage,
  fetchgit,
  pythonAtLeast,
  duckdb,
  hatchling,
  pyodbc,
}:
buildPythonPackage {
  pname = "harlequin-odbc";
  version = "0.4.0";
  pyproject = true;

  src = fetchgit {
    url = "https://git.cpatino.com/c4patino/harlequin-odbc.git";
    rev = "73afd429acdf97eb68824ff9299b2c585448c4c3";
    hash = "sha256-3G/1MWgFiN/Fg+oEqoRyaoQECpgnemH/Ydy6qyS1CBc=";
  };

  build-system = [
    hatchling
  ];

  dependencies =
    [
      pyodbc
      duckdb
    ]
    ++ lib.optional (pythonAtLeast "3.14") duckdb;

  doCheck = false;
  pythonRemoveDeps = [
    "harlequin"
  ];

  meta = {
    description = "Harlequin adapter for ODBC";
    homepage = "https://pypi.org/project/harlequin-odbc/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [pcboy];
  };
}
