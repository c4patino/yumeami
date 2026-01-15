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

    cli.dev.neovim.variant = "minimal";
  };

  home.stateVersion = "25.11";
}
