{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) types mkOption optional optionalString concatStringsSep;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace resolveHostIP;
  base = "${namespace}.services.networking";
  cfg = getAttrByNamespace config base;
  dnsCfg = getAttrByNamespace config "${base}.unbound";
in {
  options = with types;
    mkOptionsWithNamespace base {
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

  config = {
    networking.resolvconf = {
      enable = true;
      extraConfig = let
        ip =
          if dnsCfg.dnsHost != null
          then resolveHostIP cfg.devices dnsCfg.dnsHost
          else null;
        allDns = optional (ip != null) ip ++ ["1.1.1.1" "8.8.8.8" "100.100.100.100"];
      in ''
        ${optionalString (ip != null) "name_servers=${ip}"}
        search_domains="tail8b9fd9.ts.net"
        name_servers="${concatStringsSep " " allDns}"
      '';
    };
  };
}
