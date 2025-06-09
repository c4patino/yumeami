{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.desktop.apps.editors.jetbrains.clion";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "CLion";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [jetbrains.clion];

      file.".ideavimrc" = {
        source = ../.ideavimrc;
      };
    };
  };
}
