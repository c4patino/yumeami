{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.hardware.audio";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "audio";
  };

  config = mkIf cfg.enable {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;

      pulse.enable = true;

      jack.enable = true;

      alsa = {
        enable = true;
        support32Bit = true;
      };

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
  };
}
