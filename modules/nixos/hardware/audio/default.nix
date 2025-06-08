{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.hardware.audio";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "audio";
    };

  config = mkIf cfg.enable {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;

      pulse.enable = true;

      jack.enable = true;

      wireplumber.enable = true;

      alsa.enable = true;
      alsa.support32Bit = true;
    };
  };
}
