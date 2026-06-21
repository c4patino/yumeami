{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) types mkOption optional optionalString concatStringsSep;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace resolveHostIP resolveServiceHost;

  base = "${namespace}.services.networking";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      devices = mkOption {
        description = "Mapping of device names to their hostnames and IPs.";
        default = {};
        type = attrsOf (submodule {
          options = {
            ip = mkOption {
              type = str;
              description = "The ip address of the device.";
            };
            gateway = mkOption {
              type = bool;
              default = false;
              description = "Whether the device should serve as a public gateway.";
            };
          };
        });
      };
      network-services = mkOption {
        type = attrsOf (attrsOf (submodule {
          options = {
            port = mkOption {
              type = port;
              description = "Local port of the service. If not specified, the module's default is used.";
            };
            public = mkOption {
              type = bool;
              default = false;
              description = "Whether the service should be publicly accessible over *.cpatino.com.";
            };
            internal = mkOption {
              type = bool;
              default = false;
              description = "Whether the service should be internally accessible over *.yumeami.sh.";
            };
            websocket = mkOption {
              type = bool;
              default = false;
              description = "Whether to enable websocket endpoints for the service.";
            };
          };
        }));
        default = {};
        description = "Mapping of hosts to their services: networking-services.<host>.<service> = { port, internal, public }.";
      };
      gateways = mkOption {
        type = listOf str;
        description = "Names of devices which will serve as public gateways.";
      };
    };

  config = {
    networking.resolvconf = {
      enable = true;
      extraConfig = let
        unboundIP =
          if cfg.network-services ? unbound
          then resolveHostIP cfg.devices (resolveServiceHost cfg.network-services "unbound")
          else null;
        allDns = optional (unboundIP != null) unboundIP ++ ["1.1.1.1" "8.8.8.8" "100.100.100.100"];
      in ''
        ${optionalString (unboundIP != null) "name_servers=${unboundIP}"}
        search_domains="tail8b9fd9.ts.net"
        name_servers="${concatStringsSep " " allDns}"
      '';
    };
  };
}
