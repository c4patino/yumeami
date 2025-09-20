{
  config,
  lib,
  namespace,
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
        apps.launchers.launcher = "anyrun";

        env = {
          eww = enabled;
          gtk = enabled;
          hyprland = enabled;
        };

        services = {
          mako = enabled;
          hyprpaper = enabled;
          wl-clipboard = enabled;
        };
      };
      cli.media = {
        grim = enabled;
        slurp = enabled;
      };
    };
  };
}
