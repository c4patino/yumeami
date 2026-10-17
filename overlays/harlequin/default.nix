{channels, ...}: final: prev: {
  harlequin = channels.nixpkgs-unstable.harlequin.override {
    withPostgresAdapter = true;
    withOdbcAdapter = true;
    withBigQueryAdapter = false;
  };
}
