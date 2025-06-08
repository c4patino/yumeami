{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.cli.dev.lazygit";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "lazygit";
    };

  config = mkIf cfg.enable {
    programs.lazygit.enable = true;
  };
}
