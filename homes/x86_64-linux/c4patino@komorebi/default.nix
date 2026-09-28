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
      dev = {
        jiracli = enabled;
        jiratui = enabled;
        kubectl = enabled;
      };

      tools = {
        asciinema = enabled;
        presenterm = enabled;
        rustypaste = enabled;
      };
    };
  };

  programs.ssh.includes = [
    (toString (
      "${config.snowfallorg.user.home.directory}/dotfiles/secrets/crypt/komorebi-ssh.conf"
      |> config.lib.file.mkOutOfStoreSymlink
    ))
  ];

  sops.secrets = let
    inherit (config.snowfallorg) user;
  in {
    "ssh/ceferino.patino@komorebi/private" = {
      path = "${user.home.directory}/.ssh/id_ed25519-komorebi";
      sopsFile = "${inputs.self}/secrets/sops/${host}.yaml";
    };
    "ssh/ceferino.patino@komorebi/public" = {
      path = "${user.home.directory}/.ssh/id_ed25519-komorebi.pub";
      sopsFile = "${inputs.self}/secrets/sops/${host}.yaml";
    };
    "forgejo" = {
      path = "${user.home.directory}/.forgejo/token";
      sopsFile = "${inputs.self}/secrets/sops/${host}.yaml";
    };
  };

  home.stateVersion = "26.05";
}
