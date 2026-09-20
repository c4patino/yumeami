{...}: final: prev: {
  proxysql = final.callPackage ./package.nix {};
}
