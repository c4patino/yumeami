{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.cli.media.cava";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "cava";
    };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [cava];

    programs.cava = {
      enable = false;

      settings = {
        general = {
          mode = "normal";
          framerate = 144;
          bars = 0;
          bar_width = 2;
          bar_spacing = 3;
        };
        color = {
          gradient = 1;
          gradient_count = 2;
          gradient_color_2 = "'#f7768e'";
          gradient_color_1 = "'#7dcfff'";
        };
        smoothing = {
          monstercat = 1;
          waves = 1;
          gravity = 100;
        };
      };
    };
  };
}
