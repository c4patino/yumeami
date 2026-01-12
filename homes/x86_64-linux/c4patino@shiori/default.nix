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

    cli.dev.neovim.variant = "minimal";
  };

  home.stateVersion = "25.11";
}
