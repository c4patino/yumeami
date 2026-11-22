{
  config,
  inputs,
  lib,
  namespace,
  hostName,
  ...
}: let
  inherit (lib) mkDefault mkForce;
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

    virtualization = {
      docker = enabled;
      podman = enabled;
    };
  };

  users.users.c4patino.openssh.authorizedKeys.keys = mkForce [];

  networking = {
    hostName = "komorebi";
    hostId = "c6cc4687";
  };
}
