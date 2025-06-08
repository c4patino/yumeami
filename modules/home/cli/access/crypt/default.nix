{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.cli.access.crypt";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "git-crypt";
    };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [git-crypt];
  };
}
