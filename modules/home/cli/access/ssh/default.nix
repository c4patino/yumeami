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
      settings = {
        "*" = {
          AddKeysToAgent = "no";
          Compression = false;
          ControlMaster = "auto";
          ControlPath = "/tmp/ssh_%r@%h:%p-%n";
          ControlPersist = "2h";
          ForwardAgent = false;
          HashKnownHosts = false;
          ServerAliveCountMax = 3;
          ServerAliveInterval = 0;
          UserKnownHostsFile = "~/.ssh/known_hosts";
        };
        "github" = {
          HostName = "github.com";
          User = "git";
        };
        "swan" = {
          HostName = "swan.unl.edu";
          User = "c4patino";
        };
        "swan-xfer" = {
          HostName = "swan-xfer.unl.edu";
          User = "c4patino";
        };
        "nuros" = {
          HostName = "nuros.unl.edu";
          User = "cpatino2";
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
