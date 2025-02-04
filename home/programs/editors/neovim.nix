{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options.neovim.enable = lib.mkEnableOption "Neovim";

  config = lib.mkIf config.neovim.enable {
    home = {
      packages = [inputs.nixvim-config.packages.${pkgs.system}.default];
      sessionVariables.EDITOR = "nvim";
    };
  };
}
