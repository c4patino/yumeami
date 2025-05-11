{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.rider;
in {
  options.rider.enable = mkEnableOption "Rider";

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [jetbrains.rider];
      file.".ideavimrc".source = inputs.dotfiles + "/ideavimrc";
    };
  };
}
