{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkForce mkIf;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService resolveServicePort;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  isEnabled = hostHasService networkCfg.network-services hostName "autobrr";
  port = resolveServicePort networkCfg.network-services "autobrr" 7474;
in {
  config = mkIf isEnabled {
    services.autobrr = {
      enable = true;
      secretFile = config.sops.secrets."autobrr".path;

      settings = {
        host = "0.0.0.0";
        port = port;
      };
    };

    systemd = {
      tmpfiles.settings."10-autobrr" = let
        configFormat = pkgs.formats.toml {};
        autobrrConfigFile = configFormat.generate "autobrr.toml" config.services.autobrr.settings;
      in {
        "/var/lib/autobrr/config.toml"."L+" = {
          argument = "${autobrrConfigFile}";
        };
      };

      services.autobrr = let
        autobrrUser = config.users.users.autobrr;

        checkAutobrrSpace = pkgs.writeShellScriptBin "check-autobrr-space" ''
          set -euo pipefail

          required_space=$((1024 * 1024 * 1024)) # 1 Tb
          path="/var/lib/qBittorrent/qBittorrent/downloads/autobrr"

          available_space=$(${pkgs.coreutils}/bin/df "$path" | \
            ${pkgs.gawk}/bin/awk 'END {print $4}')

          [ "$available_space" -gt "$required_space" ]
        '';
      in {
        path = [checkAutobrrSpace];
        serviceConfig = {
          DynamicUser = mkForce false;
          User = autobrrUser.name;
          Group = autobrrUser.group;
          UMask = mkForce "0002";
        };
      };
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
