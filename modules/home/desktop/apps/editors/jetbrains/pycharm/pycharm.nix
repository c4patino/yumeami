{
  config,
  lib,
  namespace,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.desktop.apps.editors.jetbrains.pycharm";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "PyCharm";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [jetbrains.pycharm-professional];

      file.".ideavimrc" = {
        source = inputs.dotfiles + "/.ideavimrc";
      };
    };
  };
}
