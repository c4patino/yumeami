{
  config,
  lib,
  ...
}: {
  options = {
    audio.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable audio support";
    };
  };

  config = lib.mkIf config.audio.enable {
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
