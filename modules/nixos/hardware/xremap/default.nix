{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.hardware.xremap";
  cfg = getAttrByNamespace config base;
in {
  imports = [
    inputs.xremap.nixosModules.default
  ];

  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "xremap";
  };

  config = {
    services.xremap = {
      enable = cfg.enable;
      userName = config.users.users.c4patino.name;
      config.modmap = [
        {
          name = "Main editing remaps";
          remap = {
            CAPSLOCK = {
              alone = "ESC";
              alone_timeout_millis = 250;
              free_hold = true;
              held = "CONTROL_L";
            };
          };
        }
      ];
    };
  };
}
