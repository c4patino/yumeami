{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf types;
  inherit (lib.${namespace}) getAttrByNamespace mkOpt mkOptionsWithNamespace;

  base = "${namespace}.cli.metrics.btop";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "btop";
      package = mkOpt package pkgs.btop "The btop package to use. Use `pkgs.btop-cuda` for NVIDIA GPU support.";
    };

  config = mkIf cfg.enable {
    programs.btop = {
      enable = true;
      package = cfg.package;

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
