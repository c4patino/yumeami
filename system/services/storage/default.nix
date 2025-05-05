{...}: {
  imports = [
    ./nfs.nix
    ./postgresql.nix
    ./samba.nix
    ./syncthing.nix
  ];

  impermanence.folders = [
    "/mnt/nfs"
    "/mnt/samba"
    "/mnt/syncthing"

    "/var/lib/nfs"
    "/var/lib/samba"
  ];

  environment.sessionVariables = {
    SAMBA = "/mnt/samba";
    SYNCTHING = "/mnt/syncthing";
    NFS = "/mnt/nfs";
  };
}
