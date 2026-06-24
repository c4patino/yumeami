{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) filter mkIf optional;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService mkOutOfStoreSymlink;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  starrServices = ["radarr" "sonarr" "lidarr"];
  enabledStarrServices = filter (service: hostHasService networkCfg.network-services hostName service) starrServices;
  isEnabled = enabledStarrServices != [];
in {
  config = mkIf isEnabled {
    systemd.services.unpackerr = let
      unpackerrUser = config.users.users.unpackerr;
      systemdDependencies =
        enabledStarrServices
        |> map (service: "${service}.service");
    in {
      description = "Extract downloads for Starr apps";

      wantedBy = ["multi-user.target"];
      wants = ["network-online.target"] ++ systemdDependencies;
      after = ["network-online.target"] ++ systemdDependencies;

      serviceConfig = let
        cfg =
          "${config.users.users.c4patino.home}/dotfiles/secrets/crypt/unpackerr.toml"
          |> mkOutOfStoreSymlink pkgs;
      in {
        Type = "simple";
        User = unpackerrUser.name;
        Group = unpackerrUser.group;
        UMask = "0002";

        StateDirectory = "unpackerr";

        LoadCredential = ["unpackerr.toml:${cfg}"];

        ExecStart = "${pkgs.unpackerr}/bin/unpackerr --config %d/unpackerr.toml";
        Restart = "always";
        RestartSec = 30;
      };
    };

    users = {
      users.unpackerr = {
        isSystemUser = true;
        group = "unpackerr";
        extraGroups = ["qbittorrent"] ++ enabledStarrServices;
      };

      groups.unpackerr = {};
    };

    ${namespace}.services.storage.impermanence.folders = let
      unpackerrUser = config.users.users.unpackerr;
    in [
      {
        directory = "/var/lib/unpackerr";
        user = unpackerrUser.name;
        group = unpackerrUser.group;
        mode = "700";
      }
    ];

    systemd.services.radarr.upholds = optional (builtins.elem "radarr" enabledStarrServices) "unpackerr.service";
    systemd.services.sonarr.upholds = optional (builtins.elem "sonarr" enabledStarrServices) "unpackerr.service";
    systemd.services.lidarr.upholds = optional (builtins.elem "lidarr" enabledStarrServices) "unpackerr.service";
  };
}
