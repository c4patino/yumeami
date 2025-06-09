{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.desktop.apps.editors.jetbrains.idea";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "Idea";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [jetbrains.idea-ultimate];

      file.".ideavimrc" = {
        source = ../.ideavimrc;
      };
    };
  };
}
