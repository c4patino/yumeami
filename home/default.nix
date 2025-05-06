{
  self,
  pkgs,
  inputs,
  hostName,
  config,
  lib,
  ...
}: {
  imports = [
    ./programs
    ./wayland
    ./scripts

    inputs.sops-nix.homeManagerModules.sops
  ];
}
