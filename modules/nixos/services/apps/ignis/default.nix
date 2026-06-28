{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService resolveServicePort;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  isEnabled = hostHasService networkCfg.network-services hostName "ignis";
  port = resolveServicePort networkCfg.network-services "ignis" 8081;
in {
  config = mkIf isEnabled {
    users = {
      users.ignis = {
        isSystemUser = true;
        group = "ignis";
      };
      groups.ignis = {};
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/ignis/vaults 0750 ignis ignis -"
      "d /var/lib/ignis/data 0750 ignis ignis -"
    ];

    networking.firewall.allowedTCPPorts = [port];

    systemd.services.ignis = {
      description = "Ignis - Self-hosted Obsidian web app";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      path = with pkgs; [
        git
      ];

      environment = {
        PORT = toString port;
        VAULT_ROOT = "/var/lib/ignis/vaults";
        DATA_ROOT = "/var/lib/ignis/data";
        OBSIDIAN_ASSETS_PATH = "${pkgs.ignis}/lib/ignis/obsidian-app";
        OBSIDIAN_VERSION = "1.12.7";
      };

      preStart = ''
        mkdir -p /var/lib/ignis/vaults /var/lib/ignis/data
        chown -R ignis:ignis /var/lib/ignis/vaults /var/lib/ignis/data
      '';

      serviceConfig = {
        Type = "simple";
        User = "ignis";
        Group = "ignis";
        Restart = "always";
        RestartSec = 5;
        ExecStart = "${pkgs.ignis}/bin/ignis-server";
        StateDirectory = "ignis";
        StateDirectoryMode = "0750";
        WorkingDirectory = "${pkgs.ignis}/lib/ignis";
      };
    };

    ${namespace}.services.storage.impermanence.folders = [
      "/var/lib/ignis/data"
    ];
  };
}
