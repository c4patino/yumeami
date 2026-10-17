{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.metrics.btop";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "btop";
  };

  config = mkIf cfg.enable {
    programs.btop = {
      enable = true;
      settings = {
        color_theme = "tokyonight_night";
        proc_mem_bytes = true;
        proc_tree = true;
        show_gpu_info = true;
        temp_scale = "C";
      };
    };

    home.file.".config/btop/themes/tokyonight_night.theme".source =
      inputs.dotfiles + "/.config/btop/themes/tokyonight_night.theme";
  };
}
