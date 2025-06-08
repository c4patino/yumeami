{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.cli.dev.leetcode";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "leetcode";
    };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [leetcode-cli];

      file.".leetcode/leetcode.toml" = {
        source = "${inputs.self}/secrets/crypt/leetcode.toml";
      };
    };
  };
}
