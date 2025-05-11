{
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  nix.settings.experimental-features = ["nix-command" "flakes" "pipe-operators"];
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    disko
    parted
    git
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
