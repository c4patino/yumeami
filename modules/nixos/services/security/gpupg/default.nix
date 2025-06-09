{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.services.security.gnupg";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
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
