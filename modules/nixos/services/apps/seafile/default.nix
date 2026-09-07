{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf types;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService mkOpt mkOptionsWithNamespace mkPersistRootDir resolveServicePort;
  inherit (config.networking) hostName;

  base = "${namespace}.services.apps.seafile";
  cfg = getAttrByNamespace config base;
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  isEnabled = hostHasService networkCfg.network-services hostName "seafile";
  port = resolveServicePort networkCfg.network-services "seafile" 8080;
in {
  imports = [
    ./seafile-gc.nix
    ./seafile-server.nix
    ./seahub.nix
  ];

  options = with types;
    mkOptionsWithNamespace base {
      root = mkOpt str "/var/lib/seafile" "State directory root for seafile data";
    };

  config = mkIf isEnabled {
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

    networking.firewall.allowedTCPPorts = [port (port + 1)];

    sops.secrets."environment-file/seafile" = {};

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistRootDir config cfg.root "700")
    ];
  };
}
