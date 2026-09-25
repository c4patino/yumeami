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

  security.pki.certificateFiles = [
    "${inputs.self}/secrets/crypt/ssl/zscaler.crt"
  ];

  fileSystems."/mnt/gias" = {
    device = "//file006/GIAS";
    fsType = "drvfs";
    options = ["metadata" "uid=1000" "gid=100" "umask=022"];
  };

  networking = {
    hostName = "mutualofomaha";
    hostId = "19101c94";
  };

  system.stateVersion = "26.05";
}
