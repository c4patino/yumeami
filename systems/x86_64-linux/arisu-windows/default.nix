{
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib.${namespace}) enabled;
in {
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

  ${namespace} = {
    bundles = {
      common = enabled;
      wsl = enabled;
    };
  };

  networking = {
    hostName = "arisu-windows";
    hostId = "c6cc4687";
  };

  system.stateVersion = "26.05";
}
