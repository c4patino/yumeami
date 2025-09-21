{
  config,
  lib,
  namespace,
  pkgs,
  ...
} @ args: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.desktop.env.hyprland";
  cfg = getAttrByNamespace config base;
in {
  imports = [
    (import ./general.nix args)
    (import ./keybinds.nix args)
    (import ./rules.nix args)
  ];

  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "Hyprland";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [hyprpicker hyprpaper];

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      xwayland.enable = true;
    };
  };
}
