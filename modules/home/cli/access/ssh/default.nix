{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.access.ssh";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "ssh";
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      controlMaster = "auto";
      controlPath = "/tmp/ssh_%r@%h:%p";
      controlPersist = "2h";
      matchBlocks = {
        github = {
          hostname = "github.com";
          user = "git";
        };
        forgejo = {
          hostname = "git.yumeami.sh";
          user = "forgejo";
          port = 2222;
        };
        swan = {
          hostname = "swan.unl.edu";
          user = "c4patino";
        };
        nuros = {
          hostname = "nuros.unl.edu";
          user = "cpatino2";
        };
      };
    };
  };
}
