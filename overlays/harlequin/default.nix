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

      disabledTests =
        (old.disabledTests or [])
        # harlequin-odbc declares no adapter options (its connection string is
        # a positional argument), and this test requires every installed
        # adapter to declare at least one.
        ++ ["test_spec_covers_every_installed_adapter"];
    });
}
