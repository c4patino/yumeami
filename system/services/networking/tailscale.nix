{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.tailscale;
in {
  options.tailscale.enable = mkEnableOption "Tailscale";

  config = mkIf cfg.enable {
    services.tailscale.enable = true;
  };
}
