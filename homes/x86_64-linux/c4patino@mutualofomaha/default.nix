{
  config,
  host,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib.${namespace}) enabled;
in {
  ${namespace} = {
    bundles = {
      common = enabled;
      development = enabled;
      shell = enabled;
    };

    cli = {
      tools = {
        asciinema = enabled;
        presenterm = enabled;
        rustypaste = enabled;
      };
    };
  };

  programs.ssh.settings = {
    "github-mutual.com" = {
      HostName = "github.com";
      User = "git";
      IdentityFile = "~/.ssh/id_ed25519-mutualofomaha";
      IdentitiesOnly = true;
    };
    "lx*" = {
      ControlMaster = "no";
      ControlPath = "none";
      ControlPersist = "no";
    };
    "compass-itg" = {
      User = "pgia100";
      HostName = "lx14988";
    };
    "compass-cat" = {
      User = "pgia100";
      HostName = "lx15031";
    };
    "compass-pfix" = {
      User = "pgia100";
      HostName = "lx15322";
    };
    "compass-prod" = {
      User = "pgia100";
      HostName = "lx15282";
    };
    "compass-compile" = {
      User = "pgia100";
      HostName = "lx14413";
    };
    "forms-nonprod" = {
      User = "pgia100";
      HostName = "lx21039";
    };
    "forms-prod" = {
      User = "pgia100";
      HostName = "lx22491";
    };
    "xprn-nonprod" = {
      User = "pgia100";
      HostName = "lx201";
    };
    "xprn-prod" = {
      User = "pgia100";
      HostName = "lx185";
    };
  };

  sops.secrets = let
    inherit (config.snowfallorg) user;
  in {
    "ssh/ceferino.patino@mutualofomaha/private" = {
      path = "${user.home.directory}/.ssh/id_ed25519-mutualofomaha";
      sopsFile = "${inputs.self}/secrets/sops/${host}.yaml";
    };
    "ssh/ceferino.patino@mutualofomaha/public" = {
      path = "${user.home.directory}/.ssh/id_ed25519-mutualofomaha.pub";
      sopsFile = "${inputs.self}/secrets/sops/${host}.yaml";
    };
    "forgejo" = {
      path = "${user.home.directory}/.forgejo/token";
      sopsFile = "${inputs.self}/secrets/sops/${host}.yaml";
    };
  };

  home = {
    packages = with pkgs; [
      jira-cli-go
    ];

    stateVersion = "26.05";
  };
}
