{...}: final: prev: {
  harlequin =
    (prev.harlequin.override {
      withPostgresAdapter = true;
      withBigQueryAdapter = false;
    }) .overridePythonAttrs (old: {
      dependencies =
        (old.dependencies or [])
        ++ [final.python3Packages.harlequin-odbc];
    });
}
