{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.media.spotify";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "spotify";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [spotify-player];

    xdg.configFile = {
      "spotify-player/app.toml" = {
        source = ./app.toml;
      };
      "spotify-player/theme.toml" = {
        source = ./theme.toml;
      };
    };
  };
}
