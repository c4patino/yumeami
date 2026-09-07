{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService mkPersistRootDir resolveServicePort;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  isEnabled = hostHasService networkCfg.network-services hostName "seafile";
  port = resolveServicePort networkCfg.network-services "seafile" 8080;

  seafRoot = "/var/lib/seafile";
in {
  imports = [
    ./seaf-server.nix
    ./seahub.nix
    ./seaf-gc.nix
  ];

  config = mkIf isEnabled {
    nixpkgs.config.problems.handlers.pysaml2.broken = "ignore";

    users = {
      users = {
        "seafile" = {
          group = "seafile";
          isSystemUser = true;
        };
      };

      groups."seafile" = {};
    };

    systemd.targets.seafile = {
      wantedBy = ["multi-user.target"];
      description = "Seafile components";
    };

    networking.firewall.allowedTCPPorts = [port];

    sops.secrets."environment-file/seafile" = {};

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistRootDir config seafRoot "700")
    ];
  };
}
