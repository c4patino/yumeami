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
  base = "${namespace}.services.apps.rustypaste";
  cfg = getAttrByNamespace config base;
  userCfg = config.users.users;

  port = 5100;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "rustypaste";
  };

  config = {
    environment.systemPackages = with pkgs; [rustypaste-cli];

    systemd.services.rustypaste = mkIf cfg.enable {
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

    users = mkIf cfg.enable {
      users.rustypaste = {
        isSystemUser = true;
        group = "rustypaste";
      };

      groups.rustypaste = {};
    };

    environment.etc."rustypaste/rustypaste.toml" = mkIf cfg.enable {
      source = let
        crypt = "${inputs.self}/secrets/crypt/";
      in "${crypt}/rustypaste/server.toml";

      mode = "0755";
    };

    systemd.tmpfiles.rules = mkIf cfg.enable [
      "d /var/lib/rustypaste 2750 rustypaste rustypaste -"
    ];

    networking.firewall.allowedTCPPorts = mkIf cfg.enable [port];

    ${namespace}.services.storage.impermanence.folders = mkIf cfg.enable ["/var/lib/rustypaste"];
  };
}
