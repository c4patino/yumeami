{
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"

    ../..
  ];

  environment.systemPackages = with pkgs; [
    disko
    parted
    git
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
