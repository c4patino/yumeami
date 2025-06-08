{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.services.apps.rustypaste";
  cfg = getAttrByNamespace config base;
  userCfg = config.users.users;

  port = 5100;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "rustypaste";
    };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [rustypaste-cli];

    systemd.services.rustypaste = {
      description = "rustypaste";

      wantedBy = ["multi-user.target"];

      environment = {
        CONFIG = "/etc/rustypaste/rustypaste.toml";
      };

      serviceConfig = {
        User = userCfg.rustypaste.name;

        WorkingDirectory = "/var/lib/rustypaste";
        StateDirectory = "rustypaste";

        ExecStart = "${pkgs.rustypaste}/bin/rustypaste";
        Restart = "always";
        RestartSec = 30;
      };
    };

    users = {
      users.rustypaste = {
        isSystemUser = true;
        group = "rustypaste";
      };

      groups.rustypaste = {};
    };

    environment.etc."rustypaste/rustypaste.toml" = {
      source = let
        crypt = "${inputs.self}/secrets/crypt/";
      in "${crypt}/rustypaste/server.toml";

      mode = "0755";
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/rustypaste 2750 rustypaste rustypaste -"
    ];

    networking.firewall.allowedTCPPorts = [port];

    ${namespace}.services.storage.impermanence.folders = ["/var/lib/rustypaste"];
  };
}
