{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.hardware.camera";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "camera";
  };

  config = mkIf cfg.enable {
    services.pipewire = {
      enable = true;

      wireplumber = {
        enable = true;
        extraConfig = {
          "10-libcamera" = {
            "wireplumber.profiles" = {
              main = {
                "monitor.libcamera" = "required";
              };
            };
          };
        };
      };
    };

    systemd.user.services.imx471-webcam = {
      description = "IMX471 virtual webcam bridge";

      path = with pkgs; [
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        libcamera
      ];

      environment = {
        GST_PLUGIN_SYSTEM_PATH_1_0 =
          "${pkgs.gst_all_1.gstreamer.out}/lib/gstreamer-1.0:"
          + "${pkgs.gst_all_1.gst-plugins-base.out}/lib/gstreamer-1.0:"
          + "${pkgs.gst_all_1.gst-plugins-good.out}/lib/gstreamer-1.0:"
          + "${pkgs.libcamera.out}/lib/gstreamer-1.0";
      };

      serviceConfig = {
        ExecStart = ''
          ${pkgs.gst_all_1.gstreamer}/bin/gst-launch-1.0 \
            libcamerasrc ! queue ! videoconvert ! video/x-raw,format=NV12 ! queue ! \
            v4l2sink device=/dev/video0 sync=false
        '';

        Restart = "on-failure";
        RestartSec = 1;
      };

      wantedBy = [];
    };
  };
}
