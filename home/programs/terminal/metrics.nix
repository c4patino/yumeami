{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    bottom.enable = lib.mkEnableOption "bottom";
    nvtop.enable = lib.mkEnableOption "nvtop";
  };

  config = {
    home.packages = with pkgs; [(lib.mkIf config.nvtop.enable nvtopPackages.nvidia)];

    programs.bottom = lib.mkIf config.bottom.enable {
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
