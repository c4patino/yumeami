{
  config,
  host,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkAfter mkForce;
  inherit (lib.${namespace}) enabled;
in {
  ${namespace} = {
    bundles = {
      common = enabled;
      development = enabled;
      shell = enabled;
    };

    cli.dev.azure = {
      enable = true;
      org = "buildertrend";
    };
  };

  programs.nushell.extraConfig = mkAfter ''
    $env.BIFROST_API_KEY = open ${config.sops.secrets."bifrost/auth".path}
    $env.BT_NUGET_PAT = open ${config.sops.secrets."azure-devops/package".path}
    $env.BT_NUGET_PAT_ENCODED = open ${config.sops.secrets."azure-devops/package".path} | encode base64
    $env.HANGFIRE_REPO_USERNAME = open ${config.sops.secrets."hangfire/username".path}
    $env.HANGFIRE_REPO_PASSWORD = open ${config.sops.secrets."hangfire/password".path}
  '';

  sops.secrets = {
    "azure-devops/package".sopsFile = "${inputs.self}/secrets/sops/${host}.yaml";
    "bifrost/auth".sopsFile = "${inputs.self}/secrets/sops/${host}.yaml";
    "hangfire/password".sopsFile = "${inputs.self}/secrets/sops/${host}.yaml";
    "hangfire/username".sopsFile = "${inputs.self}/secrets/sops/${host}.yaml";
  };

  home = {
    file = {
      ".config/opencode/opencode.json".source =
        "${config.snowfallorg.user.home.directory}/dotfiles/secrets/crypt/opencode/komorebi.json"
        |> config.lib.file.mkOutOfStoreSymlink
        |> mkForce;
    };

    stateVersion = "26.05";
  };
}
