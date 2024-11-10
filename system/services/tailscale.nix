{
  lib,
  config,
  ...
}: {
  options = {
    tailscale.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable tailscale";
    };
  };

  config = lib.mkIf config.tailscale.enable {
    services.tailscale = {
      enable = true;
    };
  };
}
