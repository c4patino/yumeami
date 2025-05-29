{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.neovim;
in {
  options.neovim.enable = mkEnableOption "Neovim";

  config = mkIf cfg.enable {
    home = {
      packages = [inputs.nixvim-config.packages.${pkgs.system}.default];
      sessionVariables.EDITOR = "nvim";
    };
  };
}
