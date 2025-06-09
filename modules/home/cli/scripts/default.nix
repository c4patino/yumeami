{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.cli.scripts";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "custom shell scripts";
    };

  config = mkIf cfg.enable {
    home.packages = [
      (import ./format-drive.nix {inherit pkgs;})
      (import ./get-music-cover.nix {inherit pkgs;})
      (import ./nr.nix {inherit pkgs;})
      (import ./scratchpad.nix {inherit pkgs;})
    ];
  };
}
