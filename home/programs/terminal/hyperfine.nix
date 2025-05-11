{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.hyperfine;
in {
  options.hyperfine.enable = mkEnableOption "Hyperfine";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [hyperfine];
  };
}
