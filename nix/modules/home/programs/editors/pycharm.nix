{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.pycharm;
in {
  options.pycharm.enable = mkEnableOption "Pycharm";

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [jetbrains.pycharm-professional];
      file.".ideavimrc".source = inputs.dotfiles + "/ideavimrc";
    };
  };
}
