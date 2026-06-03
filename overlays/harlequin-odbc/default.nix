{...}: final: prev: {
  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (
        python-final: python-prev: {
          harlequin-odbc = python-final.callPackage ./package.nix {};
        }
      )
    ];
}
