{
  config,
  inputs,
  lib,
  namespace,
  system,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.dev.neovim";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base (with lib.types; {
    enable = mkEnableOption "neovim";
    variant = mkOption {
      type = enum ["minimal" "full"];
      description = "variation of yumevim to install";
      default = "full";
    };
  });

  config = mkIf cfg.enable {
    home = {
      packages = [inputs.yumevim-nix.packages.${system}.${cfg.variant}];
      sessionVariables.EDITOR = "nvim";
    };
  };
}
