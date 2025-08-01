{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.metrics.btm";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "btm";
  };

  config = mkIf cfg.enable {
    programs.bottom = {
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
