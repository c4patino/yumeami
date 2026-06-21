{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace hostHasService resolveServicePort;
  inherit (config.users) users groups;
  inherit (config.sops) secrets;
  inherit (config.networking) hostName;

  base = "${namespace}.services.apps.rustypaste";
  cfg = getAttrByNamespace config base;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  isEnabled = hostHasService networkCfg.network-services hostName "paste";
  port = resolveServicePort networkCfg.network-services "paste" 5100;
in {
  options = mkOptionsWithNamespace base {
    client = {
      enable = mkEnableOption "rustypaste client";
    };
  };

  config = {
    environment.systemPackages = mkIf cfg.client.enable (with pkgs; [rustypaste-cli]);

    systemd.services.rustypaste = mkIf isEnabled {
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
      users.rustypaste = mkIf isEnabled {
        isSystemUser = true;
        group = "rustypaste";
      };

      groups.rustypaste = mkIf (isEnabled || cfg.client.enable) {};
    };

    environment.etc."rustypaste/rustypaste.toml" = mkIf isEnabled {
      source = let
        crypt = "${inputs.self}/secrets/crypt/";
      in "${crypt}/rustypaste/server.toml";

      mode = "0755";
    };

    systemd.tmpfiles.rules = mkIf isEnabled [
      "d /var/lib/rustypaste 2750 ${users.rustypaste.name} ${users.rustypaste.group} -"
    ];

    sops.secrets = mkIf (isEnabled || cfg.client.enable) {
      "rustypaste/auth" = {
        owner = mkIf isEnabled users.rustypaste.name;
        group = groups.rustypaste.name;
        mode = "0440";
      };
      "rustypaste/delete" = {
        owner = mkIf isEnabled users.rustypaste.name;
        group = groups.rustypaste.name;
        mode = "0440";
      };
    };

    networking.firewall.allowedTCPPorts = mkIf isEnabled [port];

    ${namespace}.services.storage.impermanence.folders = mkIf isEnabled ["/var/lib/rustypaste"];
  };
}
