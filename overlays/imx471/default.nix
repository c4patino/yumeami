{...}: final: prev: {
  linuxPackages_latest = prev.linuxPackages_latest.extend (self: super: {
    imx471 = self.callPackage ../../packages/imx471/default.nix {};
  });
}
