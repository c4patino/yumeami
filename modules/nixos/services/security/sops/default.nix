{
  config,
  inputs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.services.security.sops";
  cfg = getAttrByNamespace config base;
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "sops-nix";
    };

  config = mkIf cfg.enable {
    sops = {
      defaultSopsFile = "${inputs.self}/secrets/sops/secrets.yaml";
      defaultSopsFormat = "yaml";
    };
  };
}
