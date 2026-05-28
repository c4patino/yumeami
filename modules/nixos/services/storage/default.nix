{pkgs, ...}: {
  boot = {
    supportedFilesystems = ["ntfs" "zfs" "nfs"];

    zfs.forceImportRoot = false;
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
