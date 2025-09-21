{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace enabled;
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
          gdm = enabled;
          hyprland = enabled;
          x11 = enabled;
        };
      };

      hardware = {
        audio = enabled;
        bluetooth = enabled;
        printing = enabled;
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
