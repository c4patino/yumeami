{
  self,
  lib,
  yumeami-lib,
  config,
  ...
}: let
  inherit (lib) types mkEnableOption mkOption mkIf mapAttrs' mapAttrs;
  inherit (config.networking) hostName;
  cfg = config.syncthing;

  resolveHostIP = yumeami-lib.resolveHostIP config.devices;

  ssl = "${self}/secrets/crypt/ssl/${hostName}";
in {
  options.syncthing = with types; {
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
    services.syncthing = {
      enable = true;
      dataDir = "/mnt/syncthing/";
      user = "c4patino";
      group = "syncthing";

      key = "${ssl}/syncthing.key";
      cert = "${ssl}/syncthing.crt";

      settings = {
        devices = let
          generateDeviceConfig = host: id: {
            inherit id;
            addresses = ["tcp://${resolveHostIP host}:22000"];
            autoAcceptFolders = true;
          };
        in
          cfg.devices |> mapAttrs generateDeviceConfig;

        folders = let
          generateShareConfig = folderName: sharedMachines: {
            name = folderName;
            value = {
              path = "/mnt/syncthing/${folderName}";
              enable = builtins.elem hostName sharedMachines;
              devices = sharedMachines;
            };
          };
        in
          cfg.shares |> mapAttrs' generateShareConfig;
      };
    };

    systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
  };
}
