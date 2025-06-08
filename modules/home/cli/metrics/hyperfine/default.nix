{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.cli.metrics.hyperfine";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "hyperfine";
    };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [hyperfine];
  };
}
