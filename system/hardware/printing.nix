{
  config,
  lib,
  ...
}: {
  options.printing.enable = lib.mkEnableOption "printer drivers";

  config = lib.mkIf config.printing.enable {
    services.printing.enable = true;
  };
}
