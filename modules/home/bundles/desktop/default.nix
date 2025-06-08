{
  config,
  lib,
  namespace,
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
        apps = {
          launchers = {
            anyrun = enabled;
          };
        };

        env = {
          eww = enabled;
          gtk = enabled;
          hyprland = enabled;
        };

        services = {
          mako = enabled;
          variety = enabled;
          wl-clipboard = enabled;
        };
      };
    };
  };
}
