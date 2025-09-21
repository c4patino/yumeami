{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.desktop.apps.launchers.walker";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "walker";
  };

  imports = [
    inputs.walker.homeManagerModules.default
  ];

  config = mkIf cfg.enable {
    programs.walker = {
      enable = true;
      runAsService = true;
    };
  };
}
