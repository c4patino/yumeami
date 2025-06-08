{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.cli.metrics.nvtop";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "nvtop";
    };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [nvtopPackages.nvidia];
  };
}
