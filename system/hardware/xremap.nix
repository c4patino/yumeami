{
  config,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkEnableOption;
  cfg = config.xremap;
in {
  options.xremap.enable = mkEnableOption "Xremap and keybinding remaps";

  imports = [
    inputs.xremap.nixosModules.default
  ];

  config = {
    services.xremap = {
      enable = cfg.enable;
      userName = "c4patino";
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
