{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    hyperfine.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable hyperfine programming tool";
    };
  };

  config = lib.mkIf config.lastpass.enable {
    home.packages = with pkgs; [hyperfine];
  };
}
