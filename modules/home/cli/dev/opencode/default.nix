{
  config,
  lib,
  namespace,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.dev.opencode";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "opencode";
  };

  config = mkIf cfg.enable {
    home = {
      packages = [
        (inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (_: {
          src = inputs.opencode;
        }))
      ];

      file = {
        ".config/opencode/opencode.json".source = inputs.dotfiles + "/.config/opencode/opencode.json";
        ".config/opencode/cli.json".source = inputs.dotfiles + "/.config/opencode/cli.json";
        ".config/opencode/agents".source = inputs.dotfiles + "/.config/opencode/agents";
        ".config/opencode/commands".source = inputs.dotfiles + "/.config/opencode/commands";
        ".config/opencode/themes".source = inputs.dotfiles + "/.config/opencode/themes";

        ".config/opencode/skills/gh".source = "${pkgs.gh-skill}";
        ".config/opencode/skills/gh-stack".source = "${pkgs.gh-stack}/share/skills/gh-stack/gh-stack";
        ".config/opencode/skills/jira-cli".source = "${pkgs.jira-cli-skill}";
        ".config/opencode/skills/nixos".source = inputs.dotfiles + "/.config/opencode/skills/nixos";
        ".config/opencode/skills/nushell".source = "${pkgs.nu_scripts}/share/skills/nu_scripts/nushell";
      };
    };
  };
}
