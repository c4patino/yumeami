{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.hyprland;

  varietyLock = pkgs.variety.overrideAttrs (old: {
    version = "0.8.12";
    src = pkgs.fetchFromGitHub {
      owner = "varietywalls";
      repo = "variety";
      tag = "0.8.12";
      hash = "sha256-FjnhV7vzRPVDCgUNK8CHo3arKXuwe+3xH/5AxCVgeIY=";
    };
  });
in {
  config = mkIf cfg.enable {
    home = {
      # HACK: unlock variety in order to let it update as needed
      packages = with pkgs; [
        swaybg
        varietyLock
      ];

      file.".assets/desktops/" = {
        source = inputs.dotfiles + "/desktops";
        recursive = true;
      };
    };

    wayland.windowManager.hyprland = {
      settings = {
        exec-once = [
          "swaybg &"
          "variety &"
        ];
      };
    };
  };
}
