{
  lib,
  config,
  pkgs,
  ...
}: {
  options.lastpass.enable = lib.mkEnableOption "Lastpass CLI";

  config = lib.mkIf config.lastpass.enable {
    home.packages = with pkgs; [lastpass-cli];
  };
}
