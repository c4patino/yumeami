{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.desktop.apps.editors.vscode";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "VSCode";
    };

  config = mkIf cfg.enable {
    programs.vscode = enabled;
  };
}
