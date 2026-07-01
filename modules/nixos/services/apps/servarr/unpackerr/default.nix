{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) filter mkIf optional mapAttrs' nameValuePair toUpper;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService mkPersistDir;
  inherit (config.users.users) unpackerr;
  inherit (config.networking) hostName;

  starrServices = ["radarr" "sonarr" "lidarr"];
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
  enabledStarrServices = filter (service: hostHasService networkCfg.network-services hostName service) starrServices;
  isEnabled = enabledStarrServices != [];
in {
  config = mkIf isEnabled {
    systemd.services.unpackerr = let
      systemdDependencies =
        enabledStarrServices
        |> map (service: "${service}.service");

      mkUnEnv = mapAttrs' (name: value: nameValuePair "UN_${toUpper name}" value);
    in {
      description = "Extract downloads for Starr apps";

      wantedBy = ["multi-user.target"];
      wants = ["network-online.target"] ++ systemdDependencies;
      after = ["network-online.target"] ++ systemdDependencies;

      environment = mkUnEnv {
        debug = "false";
        quiet = "false";

        interval = "2m";
        start_delay = "1m";

        retry_delay = "5m";
        max_retries = "10";

        parallel = "1";

        file_mode = "0644";
        dir_mode = "0755";

        log_files = "10";
        log_file_mb = "10";
        log_queues = "1m";
        error_stderr = "false";
        activity = "false";
      };

      serviceConfig = {
        Type = "simple";
        User = unpackerr.name;
        Group = unpackerr.group;
        UMask = "0002";
        StateDirectory = "unpackerr";
        EnvironmentFile = config.sops.secrets."environment-file/unpackerr".path;
        ExecStart = "${pkgs.unpackerr}/bin/unpackerr";
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

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistDir config "unpackerr" "/var/lib/unpackerr")
    ];

    sops.secrets."environment-file/unpackerr" = {};

    systemd.services.radarr.upholds = optional (builtins.elem "radarr" enabledStarrServices) "unpackerr.service";
    systemd.services.sonarr.upholds = optional (builtins.elem "sonarr" enabledStarrServices) "unpackerr.service";
    systemd.services.lidarr.upholds = optional (builtins.elem "lidarr" enabledStarrServices) "unpackerr.service";
  };
}
