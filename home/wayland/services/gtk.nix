{
  pkgs,
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.hyprland.enable {
    qt = {
      enable = true;
      platformTheme.name = "gtk";
    };

    gtk = {
      enable = true;
      theme = {
        package = pkgs.adw-gtk3;
        name = "adw-gtk3";
      };
    };
  };
}
