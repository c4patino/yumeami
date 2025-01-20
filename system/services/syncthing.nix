{
  self,
  lib,
  config,
  ...
}: let
  hostName = config.networking.hostName;
  sharedMachines = ["arisu" "kokoro" "chibi"];
in {
  options = {
    syncthing.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable syncthing";
    };
  };

  config = lib.mkIf config.syncthing.enable {
    services.syncthing = {
      enable = true;
      dataDir = "/mnt/syncthing/";
      user = "c4patino";
      group = "syncthing";

      key = "${self}/secrets/crypt/ssl/${hostName}/key.pem";
      cert = "${self}/secrets/crypt/ssl/${hostName}/cert.pem";

      settings = {
        devices = {
          "arisu" = {
            id = "7W2TB7D-VZZEDAP-Q2LTH7S-LUF3JOC-472P4FX-ZUQX4SG-CLPTTK6-RVUP6QQ";
            addresses = ["tcp://100.117.106.23:22000"];
            autoAcceptFolders = true;
          };
          "kokoro" = {
            id = "7ADRQXW-IB3IMNR-QCT4EXQ-4BON25I-4EFPOW6-AVJNUZK-TEDMDZQ-RH37RAB";
            addresses = ["tcp://100.69.45.111:22000"];
            autoAcceptFolders = true;
          };
          "chibi" = {
            id = "HBLTAF3-GJ7G6XS-ER6IMAZ-CY2UI7S-6BG3N3S-GF4TDIC-7USNXW7-M6TWJQU";
            addresses = ["tcp://100.101.224.25:22000"];
            autoAcceptFolders = true;
          };
        };
        folders = {
          "shared" = {
            path = "/mnt/syncthing/shared";
            enable = builtins.elem hostName sharedMachines;
            devices = sharedMachines;
          };
        };
      };
    };

    systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";

    environment.sessionVariables = {
      SHARED = "/mnt/syncthing/shared";
    };
  };
}
