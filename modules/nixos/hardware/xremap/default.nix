{
  config,
  inputs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.hardware.xremap";
  cfg = getAttrByNamespace config base;
in {
  imports = [
    inputs.xremap.nixosModules.default
  ];

  options = with types;
    mkOptionsWithNamespace base {
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
              held = "CONTROL_L";
              alone = "ESC";
              alone_timeout_millis = 250;
            };
          };
        }
      ];
    };
  };
}
