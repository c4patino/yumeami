{channels, ...}: final: prev: let
  unstable = channels.nixpkgs-unstable.extend (import ../harlequin-odbc {});
in {
  harlequin =
    (channels.nixpkgs-unstable.harlequin.override {
      withPostgresAdapter = true;
      withBigQueryAdapter = false;
    }).overridePythonAttrs (old: {
      dependencies =
        (old.dependencies or [])
        ++ [unstable.python3Packages.harlequin-odbc];
    });
}
