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
        apps.tools.obs = enabled;

        env = {
          hyprland = enabled;

          shell = {
            launchers.launcher = "noctalia";

            noctalia = enabled;
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
