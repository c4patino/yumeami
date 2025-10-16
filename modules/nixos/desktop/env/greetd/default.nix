{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.desktop.env.greetd";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "greetd";
  };

  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings.default_session.command = ''
        ${pkgs.tuigreet}/bin/tuigreet \
          --time \
          --remember \
          --cmd Hyprland
      '';
    };

    ${namespace}.services.storage.impermanence.folders = ["/var/cache/tuigreet"];
  };
}
