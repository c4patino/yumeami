{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.cli.media.spotify";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
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
