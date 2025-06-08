{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.cli.media.pandoc";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "pandoc";
    };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [pandoc];
  };
}
