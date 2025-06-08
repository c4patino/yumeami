{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.bundles.shell";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "shell utility bundle";
    };

  config = mkIf cfg.enable {
    ${namespace} = {
      cli = {
        dev = {
          zoxide = enabled;
          zsh = enabled;
        };

        media = {
          bat = enabled;
          pandoc = enabled;
          yazi = enabled;
        };
      };
    };
  };
}
