{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    pm2.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable pm2";
    };
  };

  config = lib.mkIf config.pm2.enable {
    environment.systemPackages = with pkgs; [
      pm2
    ];
  };
}
