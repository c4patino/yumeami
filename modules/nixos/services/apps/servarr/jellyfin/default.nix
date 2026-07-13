{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService mkPersistDir;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
  isEnabled = hostHasService networkCfg.network-services hostName "jellyfin";
in {
  config = mkIf isEnabled {
    services.jellyfin = {
      enable = true;
      openFirewall = true;

      forceEncodingConfig = true;
      hardwareAcceleration = {
        enable = true;
        type = "vaapi";
        device = "/dev/dri/renderD128";
      };

      transcoding = {
        enableHardwareEncoding = true;
        throttleTranscoding = true;

        hardwareDecodingCodecs = {
          h264 = true;
          hevc = true;
          hevc10bit = true;
          vp9 = true;
          av1 = true;
        };

        hardwareEncodingCodecs = {
          hevc = true;
        };
      };
    };

    users.users.jellyfin.extraGroups = [
      "video"
      "render"
    ];

    systemd.services.jellyfin.environment = {
      LIBVA_DRIVER_NAME = "radeonsi";
    };

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistDir config "jellyfin" "/var/lib/jellyfin" "700")
    ];
  };
}
