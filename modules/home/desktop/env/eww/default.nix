{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.desktop.env.eww";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "eww";
    };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        eww
        playerctl
        imagemagick
      ];

      file.".assets/nix-logo.png" = {
        source = inputs.dotfiles + "/assets/nix-logo.png";
      };
    };

    programs.eww = {
      enable = true;
      configDir = ./config;
    };
  };
}
