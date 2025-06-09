{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.desktop.apps.editors.jetbrains.rider";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "Rider";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [jetbrains.rider];

      file.".ideavimrc" = {
        source = ../.ideavimrc;
      };
    };
  };
}
