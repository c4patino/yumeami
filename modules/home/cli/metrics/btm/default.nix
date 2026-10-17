{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
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
          enable_gpu = true;
          mem_as_value = true;
          temperature_type = "c";
        };

        processes = {
          current_usage = true;
          default_grouped = true;
          case_sensitive = false;
          disable_advanced_kill = true;
          unnormalized_cpu = false;
        };
      };
    };
  };
}
