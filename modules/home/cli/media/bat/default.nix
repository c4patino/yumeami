{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.cli.media.bat";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "bat";
    };

  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;
      config = {
        theme = "base16-stylix";
        pager = "--RAW-CONTROL-CHARS --quit-if-one-screen --mouse";
        style = "plain";
      };
    };
  };
}
