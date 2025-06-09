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
  base = "${namespace}.cli.access.sops";
  cfg = getAttrByNamespace config base;
in {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "sops-nix";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [sops];
  };
}
