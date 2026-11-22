{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkDefault;
in {
  boot = {
    supportedFilesystems = ["ntfs" "zfs" "nfs"];

    zfs.forceImportRoot = mkDefault false;
  };

  services.davfs2.enable = true;

  environment = {
    systemPackages = with pkgs; [cifs-utils];

    sessionVariables = {
      SAMBA = "/mnt/samba";
      SYNCTHING = "/mnt/syncthing";
      NFS = "/mnt/nfs";
    };
  };
}
