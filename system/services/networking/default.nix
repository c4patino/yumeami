{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) types;

  nodeIP = node:
    if builtins.hasAttr node config.devices
    then config.devices.${node}.IP
    else builtins.throw "Host '${node}' does not exist in the devices configuration.";

  ip = lib.optionalString (config.unbound.dnsHost != null) "${nodeIP config.unbound.dnsHost}";

  dns = lib.concatStringsSep " " [ip "1.1.1.1" "8.8.8.8" "100.100.100.100"];
in {
  options = {
    network-manager.enable = lib.mkEnableOption "network manager";
    network-services = lib.mkOption {
      type = with types;
        attrsOf (submodule {
          options = {
            host = lib.mkOption {
              type = str;
              description = "Name of the device which is hosting the service";
            };
            port = lib.mkOption {
              type = port;
              description = "Local port of the service";
            };
            public = lib.mkOption {
              type = bool;
              default = false;
              description = "Whether the service should be publicly accessible.";
            };
          };
        });
      default = {};
      description = "Set of apps to reverse-proxy using Apache, keyed by service name.";
    };
  };

  imports = [
    ./blocky.nix
    ./httpd.nix
    ./tailscale.nix
    ./unbound.nix
  ];

  config = lib.mkIf config.network-manager.enable {
    environment.systemPackages = with pkgs; [
      networkmanagerapplet
    ];

    networking.resolvconf.enable = true;
    networking.resolvconf.extraConfig = ''
      ${lib.optionalString (config.unbound.dnsHost != null) "name_servers=${nodeIP config.unbound.dnsHost}"}
      search_domains="tail8b9fd9.ts.net"
      name_servers="${dns}"
    '';

    networking.networkmanager.enable = true;
  };
}
