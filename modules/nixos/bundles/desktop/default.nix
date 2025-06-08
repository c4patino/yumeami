{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.bundles.desktop";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
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
