{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace;
  base = "${namespace}.desktop.env.hyprland";
  cfg = getAttrByNamespace config base;
in {
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      window_rule = [
        {
          name = "suppress maximize";
          match = {
            class = ".*";
          };
          suppress_event = "maximize";
        }
      ];
      workspace_rule = [
        {
          workspace = "special:magic";
          on_created_empty = "kitty";
        }
      ];
    };
  };
}
