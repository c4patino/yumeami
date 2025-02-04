{
  lib,
  config,
  pkgs,
  ...
}: {
  options.hyperfine.enable = lib.mkEnableOption "Hyperfine";

  config = lib.mkIf config.lastpass.enable {
    home.packages = with pkgs; [hyperfine];
  };
}
