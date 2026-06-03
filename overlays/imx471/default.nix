{...}: final: prev: {
  linuxPackages_latest = prev.linuxPackages_latest.extend (self: super: {
    imx471 = self.callPackage ./package.nix {};
  });
}
