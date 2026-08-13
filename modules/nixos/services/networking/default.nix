{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  inherit (lib.${namespace}) getAttrByNamespace mkBoolOpt mkListOpt mkOpt mkOptAttrset mkOptionsWithNamespace mkRequiredOpt resolveHostIP resolveServiceHost;

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
            websocket = mkOpt (submodule {
              options = {
                enable = mkBoolOpt false "Whether to enable websocket endpoints for the service.";
                path = mkOpt str "/ws" "WebSocket path prefix for the service.";
              };
            }) {} "WebSocket configuration for the service.";
          };
        }));
        default = {};
        description = "Mapping of hosts to their services: networking-services.<host>.<service> = { port, internal, public }.";
      };
      gateways = mkListOpt str [] "Names of devices which will serve as public gateways.";
    };

  config = {
    services.resolved = {
      enable = true;
      settings.Resolve.DNSStubListener = "no";
    };

    networking.nameservers = let
      host = resolveServiceHost cfg.network-services "unbound";
      ip = resolveHostIP cfg.devices host;
    in [
      (mkIf (ip != null) ip)
      "1.1.1.1"
      "8.8.8.8"
    ];
  };
}
