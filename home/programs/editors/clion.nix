{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options.clion.enable = lib.mkEnableOption "CLion";

  config = lib.mkIf config.clion.enable {
    home = {
      packages = with pkgs; [jetbrains.clion];
      file.".ideavimrc".source = inputs.dotfiles + "/ideavimrc";
    };
  };
}
