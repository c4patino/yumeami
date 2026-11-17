{
  config,
  host,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkAfter mkEnableOption mkIf types;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace mkRequiredOpt;
  base = "${namespace}.cli.dev.gcloud";
  cfg = getAttrByNamespace config base;

  inherit (cfg) project;
  keyFile = config.sops.secrets."gcloud/auth".path;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "google cloud";
      project = mkRequiredOpt str "Default Google Cloud project ID (exported as CLOUDSDK_CORE_PROJECT).";
    };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      google-cloud-sdk
    ];

    programs = {
      bash.initExtra = mkAfter ''
        export GOOGLE_APPLICATION_CREDENTIALS="${keyFile}"
        export CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE="${keyFile}"
        export CLOUDSDK_CORE_PROJECT="${project}"
      '';

      nushell.extraConfig = mkAfter ''
        $env.GOOGLE_APPLICATION_CREDENTIALS = "${keyFile}"
        $env.CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE = "${keyFile}"
        $env.CLOUDSDK_CORE_PROJECT = "${project}"
      '';

      zsh.initContent = mkAfter ''
        export GOOGLE_APPLICATION_CREDENTIALS="${keyFile}"
        export CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE="${keyFile}"
        export CLOUDSDK_CORE_PROJECT="${project}"
      '';
    };

    sops.secrets."gcloud/auth" = {
      sopsFile = "${inputs.self}/secrets/sops/${host}.yaml";
    };
  };
}
