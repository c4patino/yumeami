{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.vscode;
in {
  options.vscode.enable = mkEnableOption "VSCode";

  config = mkIf cfg.enable {
    programs.vscode.enable = true;
  };
}
