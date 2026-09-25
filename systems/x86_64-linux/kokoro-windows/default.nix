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
    hostName = "kokoro-windows";
    hostId = "98fb2503";
  };

  system.stateVersion = "26.05";
}
