{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService resolveServicePort;
  inherit (config.users) users groups;
  inherit (config.sops) secrets;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  isEnabled = hostHasService networkCfg.network-services hostName "paste";
  port = resolveServicePort networkCfg.network-services "paste" 5100;
in {
  config = mkIf isEnabled {
    systemd.services.rustypaste = {
      description = "rustypaste";

      wantedBy = ["multi-user.target"];

      environment = {
        AUTH_TOKENS_FILE = secrets."rustypaste/auth".path;
        DELETE_TOKENS_FILE = secrets."rustypaste/delete".path;
        CONFIG = "/etc/rustypaste/rustypaste.toml";
      };

      serviceConfig = {
        User = users.rustypaste.name;

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
      "d /var/lib/rustypaste 2750 ${users.rustypaste.name} ${users.rustypaste.group} -"
    ];

    sops.secrets = {
      "rustypaste/auth" = {
        owner = users.rustypaste.name;
        group = groups.rustypaste.name;
        mode = "0440";
      };
      "rustypaste/delete" = {
        owner = users.rustypaste.name;
        group = groups.rustypaste.name;
        mode = "0440";
      };
    };

    networking.firewall.allowedTCPPorts = [port];

    ${namespace}.services.storage.impermanence.folders = ["/var/lib/rustypaste"];
  };
}
