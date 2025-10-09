{
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib.${namespace}) enabled;
in {
  imports = [
    ./hardware-configuration.nix

    inputs.disko.nixosModules.default
    (import ../../disko.nix {main = "/dev/sda";})
  ];

  ${namespace} = {
    bundles = {
      common = enabled;
    };

    services = {
      networking = {
        httpd = enabled;
      };
    };
  };

  networking = {
    hostName = "shiori";
    hostId = "asdfas";
  };

  system.stateVersion = "25.05";
}
