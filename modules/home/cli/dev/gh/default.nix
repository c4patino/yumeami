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
  base = "${namespace}.cli.dev.gh";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "gh";
  };

  config = mkIf cfg.enable {
    programs.gh = {
      enable = true;
      extensions = with pkgs; [
        gh-dash
        gh-stack
      ];
    };

    home.file.".config/gh-dash/config.yml" = {
      source = inputs.dotfiles + "/.config/gh-dash/config.yml";
    };
  };
}
