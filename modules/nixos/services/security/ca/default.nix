{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.services.security.ca";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "ca certificates";
    };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [openssl];

    security.pki.certificateFiles = [
      "${inputs.self}/secrets/crypt/ssl/ca.crt"
    ];
  };
}
