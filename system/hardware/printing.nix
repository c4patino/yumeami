{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.printing;
in {
  options.printing.enable = mkEnableOption "printer drivers";

  config = mkIf cfg.enable {
    services.printing.enable = true;
  };
}
