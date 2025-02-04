{
  lib,
  config,
  ...
}: {
  options.virtualbox.enable = lib.mkEnableOption "VirtualBox";

  config = lib.mkIf config.virtualbox.enable {
    virtualisation.virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
  };
}
