{...}: final: prev: {
  linuxPackages_latest = prev.linuxPackages_latest.extend (self: super: {
    imx471 = self.callPackage ./package.nix {};
  });
  linuxPackages_7_0 = prev.linuxPackages_7_0.extend (self: super: {
    imx471 = self.callPackage ./package.nix {};
  });
}
