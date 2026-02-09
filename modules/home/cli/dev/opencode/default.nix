{
  config,
  lib,
  namespace,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.dev.opencode";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "opencode";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [opencode];

      file = {
        ".config/opencode/opencode.json".source = inputs.dotfiles + "/.config/opencode/opencode.json";
        ".config/opencode/agent".source = inputs.dotfiles + "/.config/opencode/agent";
        ".config/opencode/command".source = inputs.dotfiles + "/.config/opencode/command";
      };
    };
  };
}
