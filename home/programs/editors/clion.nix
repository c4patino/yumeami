{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.clion;
in {
  options.clion.enable = mkEnableOption "CLion";

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [jetbrains.clion];
      file.".ideavimrc".source = inputs.dotfiles + "/ideavimrc";
    };
  };
}
