{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  inherit (config.users) users groups;
  inherit (config.sops) secrets;
  base = "${namespace}.services.apps.rustypaste";
  cfg = getAttrByNamespace config base;

  port = 5100;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "rustypaste server";
    client = {
      enable = mkEnableOption "rustypaste client";
    };
  };

  config = {
    environment.systemPackages = mkIf cfg.client.enable (with pkgs; [rustypaste-cli]);

    systemd.services.rustypaste = mkIf cfg.enable {
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
      users.rustypaste = mkIf cfg.enable {
        isSystemUser = true;
        group = "rustypaste";
      };

      groups.rustypaste = mkIf (cfg.enable || cfg.client.enable) {};
    };

    environment.etc."rustypaste/rustypaste.toml" = mkIf cfg.enable {
      source = let
        crypt = "${inputs.self}/secrets/crypt/";
      in "${crypt}/rustypaste/server.toml";

      mode = "0755";
    };

    systemd.tmpfiles.rules = mkIf cfg.enable [
      "d /var/lib/rustypaste 2750 ${users.rustypaste.name} ${users.rustypaste.group} -"
    ];

    sops.secrets = mkIf (cfg.enable || cfg.client.enable) {
      "rustypaste/auth" = {
        owner = mkIf cfg.enable users.rustypaste.name;
        group = groups.rustypaste.name;
        mode = "0440";
      };
      "rustypaste/delete" = {
        owner = mkIf cfg.enable users.rustypaste.name;
        group = groups.rustypaste.name;
        mode = "0440";
      };
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.enable [port];

    ${namespace}.services.storage.impermanence.folders = mkIf cfg.enable ["/var/lib/rustypaste"];
  };
}
