{...}: {
  boot.supportedFilesystems = ["ntfs" "zfs"];
  services.davfs2.enable = true;
}
