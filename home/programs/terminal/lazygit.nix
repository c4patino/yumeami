{
  lib,
  config,
  ...
}: {
  options.lazygit.enable = lib.mkEnableOption "lazygit";

  config = lib.mkIf config.lazygit.enable {
    programs.lazygit.enable = true;
  };
}
