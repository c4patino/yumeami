{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.dev.tuicr";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "tuicr";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [tuicr];

    home.file = {
      ".config/tuicr/config.toml".source =
        inputs.dotfiles + "/.config/tuicr/config.toml";
      ".config/tuicr/themes/tokyo-night-night.toml".source =
        inputs.dotfiles + "/.config/tuicr/themes/tokyo-night-night.toml";
      ".config/tuicr/themes/tokyonight_night.tmTheme".source =
        inputs.dotfiles + "/.config/bat/themes/tokyonight_night.tmTheme";
    };
  };
}
