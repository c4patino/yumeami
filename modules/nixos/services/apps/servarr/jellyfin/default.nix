{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
  isEnabled = hostHasService networkCfg.network-services hostName "jellyfin";
in {
  config = mkIf isEnabled {
    services.jellyfin = {
      enable = true;
      openFirewall = true;

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

    ${namespace}.services.storage.impermanence.folders = let
      jellyfinUser = config.users.users.jellyfin;
    in [
      {
        directory = "/var/lib/jellyfin";
        user = jellyfinUser.name;
        group = jellyfinUser.group;
        mode = "700";
      }
    ];
  };
}
