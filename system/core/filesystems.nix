{
  self,
  pkgs,
  lib,
  config,
  ...
}: let
  secrets = builtins.fromJSON (builtins.readFile "${self}/secrets/crypt/secrets.json");
  hostName = config.networking.hostName;
in {
  boot.supportedFilesystems = ["ntfs" "zfs"];
  services.davfs2.enable = true;

  environment.systemPackages = [pkgs.cifs-utils];
  fileSystems."/mnt/samba/shared" =
    lib.mkIf (hostName
      != "arisu")
    {
      device = "//100.117.106.23/shared";
      fsType = "cifs";
      options = let
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in ["${automount_opts},credentials=/etc/samba/.credentials,uid=1000,gid=100"];
    };

  environment.etc."samba/.credentials".text = ''
    username=${secrets.samba.username}
    password=${secrets.samba.password}
  '';
}
