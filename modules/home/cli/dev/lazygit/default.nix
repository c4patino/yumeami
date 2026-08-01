{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.dev.lazygit";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "lazygit";
  };

  config = mkIf cfg.enable {
    programs.lazygit.enable = true;

    home.file.".config/lazygit/config.yml" = {
      source = inputs.dotfiles + "/.config/lazygit/config.yaml";
    };
  };
}
