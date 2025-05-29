{pkgs, ...}: {
  boot.supportedFilesystems = ["ntfs" "zfs" "nfs"];
  services.davfs2.enable = true;

  environment.systemPackages = with pkgs; [cifs-utils];
}
