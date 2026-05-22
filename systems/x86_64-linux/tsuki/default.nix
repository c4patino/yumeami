{
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib.${namespace}) enabled;
in {
  imports = [
    inputs.disko.nixosModules.default
    (import ../../disko.nix {main = "/dev/nvme0n1";})
  ];

  ${namespace} = {
    bundles = {
      common = enabled;
    };
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
  };

  networking = {
    hostName = "tsuki";
    hostId = "3d19e767";
  };

  system.stateVersion = "25.11";
}
