{
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; {
  ${namespace} = {
    bundles = {
      common = enabled;
      development = enabled;
      shell = enabled;
    };
  };

  home.stateVersion = "25.11";
}
