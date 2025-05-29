{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.idea;
in {
  options.idea.enable = mkEnableOption "IntelliJ IDEA";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [jetbrains.idea-ultimate];
    home.file.".ideavimrc".source = inputs.dotfiles + "/ideavimrc";
  };
}
