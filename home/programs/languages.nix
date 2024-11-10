{
  lib,
  config,
  inputs,
  ...
}: {
  options = {
    languages.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable support for multiple programming languages";
    };
  };

  config = lib.mkIf config.languages.enable {
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
