{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.desktop.apps.tools.presenterm";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "presenterm";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      presenterm

      # sub-dependencies for rendering various slide types
      d2
      mermaid-cli
      pandoc
      python313Packages.weasyprint
      texliveFull
      typst
    ];
  };
}
