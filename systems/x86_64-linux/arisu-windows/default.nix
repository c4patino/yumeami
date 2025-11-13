{
  lib,
  namespace,
  ...
}: let
  inherit (lib.${namespace}) enabled;
in {
  ${namespace} = {
    bundles = {
      common = enabled;
    };
  };

  networking = {
    hostName = "arisu-windows";
    hostId = "";
  };

  system.stateVersion = "25.05";
}
