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
        apps.tools.obs = enabled;

        env = {
          hyprland = enabled;

          shell = {
            launchers.launcher = "walker";

            eww = enabled;
            hyprpaper = enabled;
            mako = enabled;
          };

          theme.gtk = enabled;

          tools = {
            wl-clipboard = enabled;
          };
        };
      };
    };

    home.packages = with pkgs; [
      rclip
    ];
  };
}
