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
      development = enabled;
      shell = enabled;
    };

    cli = {
      tools = {
        presenterm = enabled;
      };
    };
  };
}
