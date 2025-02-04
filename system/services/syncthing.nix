{
  self,
  lib,
  config,
  ...
}: let
  inherit (lib) types mapAttrs' mapAttrs;
  inherit (config.networking) hostName;
in {
  options.syncthing = {
    enable = lib.mkEnableOption "Syncthing";
    devices = lib.mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "A map of host names to their respective device IDs for Syncthing.";
    };
    shares = lib.mkOption {
      type = types.attrsOf (types.listOf types.str);
      default = {};
      description = "A map of folder names to the list of hostnames with which the folder is shared.";
    };
  };

  config = lib.mkIf config.syncthing.enable {
    services.syncthing = {
      enable = true;
      dataDir = "/mnt/syncthing/";
      user = "c4patino";
      group = "syncthing";

      key = "${self}/secrets/crypt/${hostName}/key.pem";
      cert = "${self}/secrets/crypt/${hostName}/cert.pem";

      settings = {
        devices =
          mapAttrs (hostName: id: let
            ip =
              if builtins.hasAttr hostName config.devices
              then config.devices.${hostName}.IP
              else builtins.throw "Missing IP for device '${hostName}' in the Syncthing configuration.";
          in {
            inherit id;
            addresses = ["tcp://${ip}:22000"];
            autoAcceptFolders = true;
          })
          config.syncthing.devices;

        folders =
          mapAttrs' (folderName: sharedMachines: {
            name = folderName;
            value = {
              path = "/mnt/syncthing/${folderName}";
              enable = builtins.elem hostName sharedMachines;
              devices = sharedMachines;
            };
          })
          config.syncthing.shares;
      };
    };

    systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
  };
}
