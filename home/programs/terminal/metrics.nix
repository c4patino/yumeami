{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  btmCfg = config.bottom;
  nvtopCfg = config.nvtop;
in {
  options = {
    bottom.enable = mkEnableOption "bottom";
    nvtop.enable = mkEnableOption "nvtop";
  };

  config = {
    home.packages = with pkgs; [(mkIf nvtopCfg.enable nvtopPackages.nvidia)];

    programs.bottom = mkIf btmCfg.enable {
      enable = true;
      settings = {
        flags = {
          current_usage = true;
          group_processes = true;
          case_sensitive = false;
          mem_as_value = true;
          enable_gpu = true;
          disable_advanced_kill = true;
          unnormalized_cpu = false;
          temperature_type = "c";
        };
      };
    };
  };
}
