{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.services.security.gnupg";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "gnupg";
    };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [gnupg];

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
}
