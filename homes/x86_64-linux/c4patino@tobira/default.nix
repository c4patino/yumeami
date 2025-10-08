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
      shell = enabled;
    };
  };

  home.stateVersion = "25.05";
}
