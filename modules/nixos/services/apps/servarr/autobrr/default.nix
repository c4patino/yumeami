{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkForce mkIf;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService getServicePort flattenHostServices;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
  networkServices = flattenHostServices networkCfg.network-services;

  isEnabled = hostHasService networkCfg.network-services hostName "autobrr";
  port = getServicePort networkServices "autobrr" 7474;
in {
  config = mkIf isEnabled {
    services.autobrr = {
      enable = true;
      secretFile = config.sops.secrets."autobrr".path;
    };

    systemd.services.autobrr.serviceConfig = let
      autobrrUser = config.users.users.autobrr;
    in {
      DynamicUser = mkForce false;
      User = autobrrUser.name;
      Group = autobrrUser.group;
      UMask = mkForce "0002";
    };

    sops.secrets = {
      "autobrr" = {
        owner = config.users.users.autobrr.name;
        group = config.users.users.autobrr.group;
      };
    };

    users = {
      users.autobrr = {
        isSystemUser = true;
        group = "autobrr";
        extraGroups = ["jellyfin" "qbittorrent"];
      };

      groups.autobrr = {};
    };

    networking.firewall.allowedTCPPorts = [port];

    ${namespace}.services.storage.impermanence.folders = let
      autobrrUser = config.users.users.autobrr;
    in [
      {
        directory = "/var/lib/autobrr";
        user = autobrrUser.name;
        group = autobrrUser.group;
        mode = "700";
      }
    ];
  };
}
