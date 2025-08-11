{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace enabled;
  base = "${namespace}.bundles.shell";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "shell utility bundle";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      dust
      ripgrep
      ripgrep-all
      wiki-tui
    ];

    ${namespace} = {
      cli = {
        dev = {
          fzf = enabled;
          zoxide = enabled;
          zsh = enabled;
        };

        media = {
          bat = enabled;
          pandoc = enabled;
          yazi = enabled;
        };

        scripts = enabled;
      };
    };
  };
}
