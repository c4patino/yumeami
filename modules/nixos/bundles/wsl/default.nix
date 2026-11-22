{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkForce mkIf;
  inherit (lib.${namespace}) enabled getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.bundles.wsl";
  cfg = getAttrByNamespace config base;
in {
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "wsl bundle";
  };

  config = mkIf cfg.enable {
    services.resolved.enable = mkForce false;

    programs.nh = {
      enable = true;
      clean.enable = true;
    };

    sops.age.keyFile = let
      inherit (config.networking) hostName;
      crypt = "${config.users.users.c4patino.home}/dotfiles/secrets/crypt";
    in "${crypt}/age/${hostName}/keys.txt";

    wsl = {
      enable = true;
      defaultUser = "c4patino";
    };

    networking.nameservers = mkForce [];
  };
}
