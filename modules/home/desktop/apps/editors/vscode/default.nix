{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.${namespace}) enabled getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.desktop.apps.editors.vscode";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "VSCode";
  };

  config = mkIf cfg.enable {
    programs.vscode = enabled;
  };
}
