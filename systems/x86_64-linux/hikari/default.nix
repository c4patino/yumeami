{
  lib,
  modulesPath,
  pkgs,
  namespace,
  ...
}: let
  inherit (lib.${namespace}) enabled;
in {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  isoImage.edition = "hikari";

  ${namespace} = {
    bundles.common = enabled;
    services.security.ca = enabled;
  };

  networking.hostName = "hikari";

  environment.systemPackages = with pkgs; [
    disko
    parted
  ];

  services.openssh.enable = true;
}
