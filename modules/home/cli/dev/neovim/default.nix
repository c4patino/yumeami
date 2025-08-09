{
  config,
  inputs,
  lib,
  namespace,
  system,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.dev.neovim";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "neovim";
  };

  config = mkIf cfg.enable {
    home = {
      packages = [inputs.yumevim-nix.packages.${system}.default];
      sessionVariables.EDITOR = "nvim";
    };
  };
}
