{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.desktop.apps.media.zathura";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "Zathura";
  };

  config = mkIf cfg.enable {
    programs.zathura = {
      enable = true;
      extraConfig = ''
        set notification-error-bg "#f7768e"
        set notification-error-fg "#c0caf5"
        set notification-warning-bg "#e0af68"
        set notification-warning-fg "#414868"
        set notification-bg "#1a1b26"
        set notification-fg "#c0caf5"
        set completion-bg "#1a1b26"
        set completion-fg "#a9b1d6"
        set completion-group-bg "#1a1b26"
        set completion-group-fg "#a9b1d6"
        set completion-highlight-bg "#414868"
        set completion-highlight-fg "#c0caf5"
        set index-bg "#1a1b26"
        set index-fg "#c0caf5"
        set index-active-bg "#414868"
        set index-active-fg "#c0caf5"
        set inputbar-bg "#1a1b26"
        set inputbar-fg "#c0caf5"
        set statusbar-bg "#1a1b26"
        set statusbar-fg "#c0caf5"
        set default-bg "#1a1b26"
        set default-fg "#c0caf5"
        set render-loading true
        set render-loading-fg "#1a1b26"
        set render-loading-bg "#c0caf5"
        set recolor-lightcolor "#1a1b26"
        set recolor-darkcolor "#c0caf5"
      '';
    };
  };
}
