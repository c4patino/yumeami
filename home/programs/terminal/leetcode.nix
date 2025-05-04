{
  pkgs,
  lib,
  config,
  inputs,
  secrets,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.leetcode;
in {
  options.leetcode.enable = mkEnableOption "Leetcode CLI";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [leetcode-cli];

    home.file.".leetcode/leetcode.toml".text = ''
      ${builtins.readFile (inputs.dotfiles + "/leetcode.toml")}

      [cookies]
      csrf = '${secrets.leetcode.csrf}'
      session = '${secrets.leetcode.session}'
      site = "leetcode.com"
    '';
  };
}
