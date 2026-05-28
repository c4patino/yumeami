{
  config,
  lib,
  namespace,
  pkgs,
  ...
} @ args: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace enabled;
  base = "${namespace}.cli.media.yazi";
  cfg = getAttrByNamespace config base;
in {
  imports = [
    (import ./keymap.nix args)
    (import ./openers.nix args)
  ];

  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "yazi";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      mpv
      imv
      jq
      exiftool
    ];

    programs.yazi = {
      enable = true;
      shellWrapperName = "yy";

      settings = {
        log = enabled;

        mgr = {
          ratio = [1 3 3];
          sort_by = "natural";
          sort_reverse = false;
          sort_dir_first = true;
          show_hidden = true;
          show_symlink = true;
          linemode = "size";
        };

        preview = {
          cache_dir = "${config.xdg.cacheHome}";
          max_height = 900;
          max_width = 600;
        };
      };
    };
  };
}
