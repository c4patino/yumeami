{
  lib,
  config,
  ...
}: let
  port = 5150;
in {
  options.glance.enable = lib.mkEnableOption "glance";

  imports = [
    ./layout.nix
  ];

  config = lib.mkIf config.glance.enable {
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
