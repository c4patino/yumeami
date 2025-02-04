{
  pkgs,
  lib,
  config,
  inputs,
  secrets,
  ...
}: {
  options.leetcode.enable = lib.mkEnableOption "Leetcode CLI";

  config = lib.mkIf config.leetcode.enable {
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
