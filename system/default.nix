{lib, ...}: let
  inherit (lib) types mkOption;
in {
  options.devices = with types;
    mkOption {
      description = "Mapping of device names to their hostnames and IPs.";
      default = {};
      type = attrsOf (submodule {
        options.IP = mkOption {
          type = str;
          description = "The IP address of the device.";
        };
      });
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
