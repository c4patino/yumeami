{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options.pycharm.enable = lib.mkEnableOption "Pycharm";

  config = lib.mkIf config.pycharm.enable {
    home = {
      packages = with pkgs; [jetbrains.pycharm-professional];
      file.".ideavimrc".source = inputs.dotfiles + "/ideavimrc";
    };
  };
}
