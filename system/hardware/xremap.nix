{
  config,
  lib,
  inputs,
  ...
}: {
  options.xremap.enable = lib.mkEnableOption "Xremap and keybinding remaps";

  imports = [
    inputs.xremap.nixosModules.default
  ];

  config = {
    services.xremap = {
      enable = config.xremap.enable;
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
