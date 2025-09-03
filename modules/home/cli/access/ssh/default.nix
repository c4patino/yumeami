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
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          addKeysToAgent = "no";
          compression = false;
          controlMaster = "auto";
          controlPath = "/tmp/ssh_%r@%h:%p";
          controlPersist = "2h";
          forwardAgent = false;
          hashKnownHosts = false;
          serverAliveCountMax = 3;
          serverAliveInterval = 0;
          userKnownHostsFile = "~/.ssh/known_hosts";
        };
        "forgejo" = {
          hostname = "git.yumeami.sh";
          user = "forgejo";
          port = 2222;
        };
        "github" = {
          hostname = "github.com";
          user = "git";
        };
        "swan" = {
          hostname = "swan.unl.edu";
          user = "c4patino";
        };
        "swan-xfer" = {
          hostname = "swan-xfer.unl.edu";
          user = "c4patino";
        };
        "nuros" = {
          hostname = "nuros.unl.edu";
          user = "cpatino2";
        };
      };
    };
  };
}
