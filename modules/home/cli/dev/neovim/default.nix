{
  config,
  inputs,
  lib,
  namespace,
  system,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace mkOpt;
  base = "${namespace}.cli.dev.neovim";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base (with lib.types; {
    enable = mkEnableOption "neovim";
    variant = mkOpt (enum ["minimal" "default" "full"]) "default" "variation of yumevim to install";
  });

  config = mkIf cfg.enable {
    home = {
      packages = [inputs.yumevim-nix.packages.${system}.${cfg.variant}];
      sessionVariables.EDITOR = "nvim";
    };
  };
}
