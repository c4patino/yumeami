{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService resolveServicePort mkPersistDir;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  isEnabled = hostHasService networkCfg.network-services hostName "ignis";
  port = resolveServicePort networkCfg.network-services "ignis" 5125;

  vault-key-provision = import ./vault-key-provision.nix {inherit pkgs;};
  vault-sync = import ./vault-sync.nix {inherit pkgs;};
in {
  config = mkIf isEnabled {
    systemd = {
      services = {
        ignis = {
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

        ignis-vault-key-provision = {
          description = "Provision SSH key and git config for ignis vault sync";
          after = ["network.target"];
          before = ["ignis-vault-sync.service"];
          wantedBy = ["multi-user.target"];
          environment.HOME = "/var/lib/ignis/data";
          serviceConfig = {
            Type = "oneshot";
            User = "ignis";
            Group = "ignis";
            ExecStart = "${vault-key-provision}/bin/ignis-vault-key-provision";
            RemainAfterExit = true;
          };
        };

        ignis-vault-sync = {
          description = "Auto-commit and pull ignis vaults";
          after = ["ignis-vault-key-provision.service"];
          path = with pkgs; [
            openssh
          ];
          environment.HOME = "/var/lib/ignis/data";
          serviceConfig = {
            Type = "oneshot";
            User = "ignis";
            Group = "ignis";
            ExecStart = "${vault-sync}/bin/ignis-vault-sync";
          };
        };
      };

      timers = {
        ignis-vault-sync = {
          description = "Timer for ignis vault sync";
          wantedBy = ["timers.target"];
          timerConfig.OnUnitActiveSec = "1m";
        };
      };
    };

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

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistDir config "ignis" "/var/lib/ignis")
    ];
  };
}
