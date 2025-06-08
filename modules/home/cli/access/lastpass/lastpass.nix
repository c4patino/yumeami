{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.cli.access.lastpass";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "lastpass-cli";
    };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [lastpass-cli];
  };
}
