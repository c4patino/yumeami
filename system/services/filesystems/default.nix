{...}: {
  imports = [
    ./nfs.nix
    ./samba.nix
    ./syncthing.nix
  ];

  environment.sessionVariables = {
    SAMBA = "/mnt/samba";
    SYNCTHING = "/mnt/syncthing";
    NFS = "/mnt/nfs";
  };
}
