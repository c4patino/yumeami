{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.desktop.env.shell.noctalia";
  cfg = getAttrByNamespace config base;
in {
  imports = [
    inputs.noctalia.homeModules.default

    ./config/bar.nix
    ./config/control-center.nix
    ./config/general.nix
    ./config/shell.nix
  ];

  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "Noctalia";
  };

  config = mkIf cfg.enable {
    programs.noctalia = {
      enable = true;
      systemd.enable = true;
    };

    home = {
      packages = with pkgs; [
        playerctl
      ];

      file.".assets/desktops/" = {
        source =
          "${config.snowfallorg.user.home.directory}/dotfiles/inputs/dotfiles/.assets/desktops"
          |> config.lib.file.mkOutOfStoreSymlink;
      };
    };
  };
}
