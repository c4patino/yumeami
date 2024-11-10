{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    virtualbox.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable VirtualBox support";
    };
  };

  config = lib.mkIf config.virtualbox.enable {
    virtualisation.virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
  };
}
