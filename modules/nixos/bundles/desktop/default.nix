{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.${namespace}) enabled getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.bundles.desktop";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "desktop environment bundle";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      desktop = {
        env = {
          greetd = enabled;
          hyprland = enabled;
          x11 = enabled;
        };
      };

      hardware = {
        audio = enabled;
        bluetooth = enabled;
        printing = enabled;
      };

      services = {
        security = {
          gnome-keyring = enabled;
        };
      };
    };

    fonts = {
      enableDefaultPackages = true;
      fontDir.enable = true;

      packages = with pkgs; [
        corefonts
        nerd-fonts.meslo-lg
        nerd-fonts.caskaydia-cove
        nerd-fonts.jetbrains-mono
        noto-fonts
        noto-fonts-cjk-sans
      ];
    };
  };
}
