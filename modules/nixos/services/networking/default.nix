{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) types mkOption optional optionalString concatStringsSep;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace resolveHostIP flattenHostServices mkRequiredOpt mkBoolOpt mkOptAttrset mkListOpt;

  base = "${namespace}.services.networking";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      devices = mkOptAttrset (submodule {
        options = {
          ip = mkRequiredOpt str "The ip address of the device.";
          gateway = mkBoolOpt false "Whether the device should serve as a public gateway.";
        };
      }) {} "Mapping of device names to their hostnames and IPs.";
      network-services = mkOption {
        type = attrsOf (attrsOf (submodule {
          options = {
            port = mkRequiredOpt port "Local port of the service. If not specified, the module's default is used.";
            public = mkBoolOpt false "Whether the service should be publicly accessible over *.cpatino.com.";
            internal = mkBoolOpt false "Whether the service should be internally accessible over *.yumeami.sh.";
            websocket = mkBoolOpt false "Whether to enable websocket endpoints for the service.";
          };
        }));
        default = {};
        description = "Mapping of hosts to their services: networking-services.<host>.<service> = { port, internal, public }.";
      };
      gateways = mkListOpt str [] "Names of devices which will serve as public gateways.";
    };

  config = {
    networking.resolvconf = {
      enable = true;
      extraConfig = let
        flatServices = flattenHostServices cfg.network-services;
        unboundIP =
          if flatServices ? unbound
          then resolveHostIP cfg.devices flatServices.unbound.host
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
