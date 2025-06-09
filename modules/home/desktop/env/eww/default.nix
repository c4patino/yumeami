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
  base = "${namespace}.desktop.env.eww";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
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
