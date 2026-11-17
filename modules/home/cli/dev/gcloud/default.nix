{
  config,
  host,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkAfter mkEnableOption mkIf mkOption optionalString types;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.dev.gcloud";
  cfg = getAttrByNamespace config base;

  inherit (cfg) project;
  keyFile = config.sops.secrets."gcloud/auth".path;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "google cloud";

    project = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default Google Cloud project ID (exported as CLOUDSDK_CORE_PROJECT).";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      google-cloud-sdk
    ];

    programs = {
      bash.initExtra = mkAfter ''
        export GOOGLE_APPLICATION_CREDENTIALS="${keyFile}"
        export CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE="${keyFile}"
        ${optionalString (project != null) ''export CLOUDSDK_CORE_PROJECT="${project}"''}
      '';

      nushell.extraConfig = mkAfter ''
        $env.GOOGLE_APPLICATION_CREDENTIALS = "${keyFile}"
        $env.CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE = "${keyFile}"
        ${optionalString (project != null) ''$env.CLOUDSDK_CORE_PROJECT = "${project}"''}
      '';

      zsh.initContent = mkAfter ''
        export GOOGLE_APPLICATION_CREDENTIALS="${keyFile}"
        export CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE="${keyFile}"
        ${optionalString (project != null) ''export CLOUDSDK_CORE_PROJECT="${project}"''}
      '';
    };

    sops.secrets."gcloud/auth" = {
      sopsFile = "${inputs.self}/secrets/sops/${host}.yaml";
    };
  };
}
