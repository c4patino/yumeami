{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkForce;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.media.bat";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "bat";
  };

  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;
      config = {
        theme = mkForce "tokyonight_night";
        pager = "--RAW-CONTROL-CHARS --quit-if-one-screen --mouse";
        style = "plain";
      };
      themes = {
        "tokyonight_night" = {
          src = inputs.dotfiles + "/.config/bat/themes";
          file = "tokyonight_night.tmTheme";
        };
      };
    };
  };
}
