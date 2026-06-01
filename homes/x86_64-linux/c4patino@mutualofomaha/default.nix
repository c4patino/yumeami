{
  config,
  host,
  inputs,
  lib,
  namespace,
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
        presenterm = enabled;
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

  home.stateVersion = "26.05";
}
