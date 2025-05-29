{inputs, ...}: {
  imports = [
    ./programs
    ./wayland
    ./scripts

    inputs.sops-nix.homeManagerModules.sops
  ];
}
