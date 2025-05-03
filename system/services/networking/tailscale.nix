{
  lib,
  config,
  ...
}: {
  options.tailscale.enable = lib.mkEnableOption "Tailscale";

  config = lib.mkIf config.tailscale.enable {
    services.tailscale.enable = true;
  };
}
