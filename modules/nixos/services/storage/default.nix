{pkgs, ...}: {
  boot.supportedFilesystems = ["ntfs" "zfs" "nfs"];

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
