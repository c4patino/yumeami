{
  lib,
  namespace,
  pkgs,
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

  home = {
    packages = with pkgs; [
      nvtopPackages.amd
    ];

    stateVersion = "26.05";
  };
}
