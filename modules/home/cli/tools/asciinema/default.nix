{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.tools.asciinema";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "asciinema";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        asciinema
      ];

      file = {
        ".config/asciinema/config.toml" = {
          source = inputs.dotfiles + "/.config/asciinema/config.toml";
        };
      };
    };
  };
}
