{
  lib,
  namespace,
  ...
}: let
  inherit (lib.${namespace}) disabled enabled;
in {
  imports = [./stylix.nix];

  ${namespace} = {
    bundles = {
      common = disabled;

      development = enabled;
      shell = enabled;
    };
  };

  home.stateVersion = "25.11";
}
