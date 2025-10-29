{
  config,
  host,
  inputs,
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

    sops.secrets = let
      inherit (config.snowfallorg) user;
    in {
      "ssh/${user.name}/private" = {
        path = "${user.home.directory}/.ssh/id_ed25519";
        sopsFile = "${inputs.self}/secrets/sops/${host}.yaml";
      };
      "ssh/${user.name}/public" = {
        path = "${user.home.directory}/.ssh/id_ed25519.pub";
        sopsFile = "${inputs.self}/secrets/sops/${host}.yaml";
      };
    };
  };
}
