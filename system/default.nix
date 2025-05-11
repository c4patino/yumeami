{lib, ...}: let
  inherit (lib) types mkOption;
in {
  options = with types; {
    devices = mkOption {
      description = "Mapping of device names to their hostnames and IPs.";
      default = {};
      type = attrsOf (submodule {
        options.IP = mkOption {
          type = str;
          description = "The IP address of the device.";
        };
      });
    };
    network-services = mkOption {
      type = attrsOf (submodule {
        options.host = mkOption {
          type = str;
          description = "Name of the device which is hosting the service";
        };
        options.port = mkOption {
          type = port;
          description = "Local port of the service";
        };
        options.public = mkOption {
          type = bool;
          default = false;
          description = "Whether the service should be publicly accessible.";
        };
      });
      default = {};
      description = "Set of apps to reverse-proxy using Apache, keyed by service name.";
    };
  };

  imports = [
    ./core
    ./gaming
    ./hardware
    ./services
    ./virtualization
    ./hyprland.nix
    ./impermanence.nix
    ./secrets.nix
  ];
}
