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
    ];

    ${namespace} = {
      cli = {
        dev = {
          carapace = enabled;
          fzf = enabled;
          nushell = enabled;
          starship = enabled;
          zoxide = enabled;
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
