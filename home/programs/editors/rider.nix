{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options.rider.enable = lib.mkEnableOption "Rider";

  config = lib.mkIf config.rider.enable {
    home = {
      packages = with pkgs; [jetbrains.rider];
      file.".ideavimrc".source = inputs.dotfiles + "/ideavimrc";
    };
  };
}
