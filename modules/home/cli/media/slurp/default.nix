{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.cli.media.slurp";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "grim";
    };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [slurp];
  };
}
