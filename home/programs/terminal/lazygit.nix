{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.lazygit;
in {
  options.lazygit.enable = mkEnableOption "lazygit";

  config = mkIf cfg.enable {
    programs.lazygit.enable = true;
  };
}
