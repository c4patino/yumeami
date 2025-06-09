{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.dev.leetcode";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
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
