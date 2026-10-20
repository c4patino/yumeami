{channels, ...}: final: prev: {
  harlequin = channels.nixpkgs-unstable.harlequin.override {
    withPostgresAdapter = true;
    withOdbcAdapter = false;
    withBigQueryAdapter = false;
  };
}
