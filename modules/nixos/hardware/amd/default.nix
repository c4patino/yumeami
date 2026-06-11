{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.hardware.amd";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "amd";
  };

  config = mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages = with pkgs; [
        mesa
        libva
        libva-utils
      ];

      extraPackages32 = with pkgs.pkgsi686Linux; [
        mesa
      ];
    };

    services.xserver.videoDrivers = ["amdgpu"];

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "radeonsi";
    };
  };
}
