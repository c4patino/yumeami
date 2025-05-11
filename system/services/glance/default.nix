{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.glance;

  port = 5150;
in {
  options.glance.enable = mkEnableOption "glance";

  imports = [
    ./layout.nix
  ];

  config = mkIf cfg.enable {
    services.glance = {
      enable = true;
      openFirewall = true;

      settings = {
        server = {
          host = "0.0.0.0";
          port = port;
        };
      };
    };
  };
}
