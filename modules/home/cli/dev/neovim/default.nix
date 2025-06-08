{
  config,
  inputs,
  lib,
  namespace,
  system,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.cli.dev.neovim";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "neovim";
    };

  config = mkIf cfg.enable {
    home = {
      packages = [inputs.nixvim-config.packages.${system}.default];
      sessionVariables.EDITOR = "nvim";
    };
  };
}
