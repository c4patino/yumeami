{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options.idea.enable = lib.mkEnableOption "IntelliJ IDEA";

  config = lib.mkIf config.idea.enable {
    home.packages = with pkgs; [jetbrains.idea-ultimate];
    home.file.".ideavimrc".source = inputs.dotfiles + "/ideavimrc";
  };
}
