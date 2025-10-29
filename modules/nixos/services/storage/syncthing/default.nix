{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) types mkEnableOption mkOption mkIf mapAttrs mapAttrs';
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace resolveHostIP;
  inherit (config.networking) hostName;
  base = "${namespace}.services.storage.syncthing";
  cfg = getAttrByNamespace config base;
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "Syncthing";
      devices = mkOption {
        type = attrsOf str;
        default = {};
        description = "A map of host names to their respective device IDs for Syncthing.";
      };
      shares = mkOption {
        type = attrsOf (listOf str);
        default = {};
        description = "A map of folder names to the list of hostnames with which the folder is shared.";
      };
    };

  config = mkIf cfg.enable {
    services.syncthing = let
      inherit (config.sops) secrets;
    in {
      enable = true;
      dataDir = "/mnt/syncthing/";
      user = "c4patino";
      group = "syncthing";

      cert = secrets."ssl/syncthing/cert".path;
      key = secrets."ssl/syncthing/key".path;

      settings = {
        devices = let
          mkDeviceConfig = host: id: {
            inherit id;
            addresses = ["tcp://${resolveHostIP networkCfg.devices host}:22000"];
            autoAcceptFolders = true;
          };
        in
          cfg.devices |> mapAttrs mkDeviceConfig;

        folders = let
          mkShare = folderName: sharedMachines: {
            name = folderName;
            value = {
              path = "/mnt/syncthing/${folderName}";
              enable = builtins.elem hostName sharedMachines;
              devices = sharedMachines;
            };
          };
        in
          cfg.shares |> mapAttrs' mkShare;
      };
    };

    systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
  };
}
