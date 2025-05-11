{
  lib,
  config,
  inputs,
  ...
}: let
  inherit (lib) types mkOption mkIf;
  cfg = config.languages;
in {
  options.languages.enable = with types;
    mkOption {
      type = bool;
      default = false;
      description = "Enable support for multiple programming languages";
    };

  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    xdg.configFile."direnv/direnvrc" = {
      source = inputs.dotfiles + "/direnvrc";
    };
  };
}
