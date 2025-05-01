{inputs, ...}: {
  imports = [
    ../..
    ./hardware-configuration.nix

    inputs.disko.nixosModules.default
    (import ../disko.nix {
      main = "/dev/mmcblk1";
      extras = [];
    })
  ];

  networking = {
    hostName = "chibi";
    hostId = "9245f27e";
  };

  ntfy.enable = true;

  nfs = {
    enable = true;
    shares = [
      {
        name = "slurm";
        whitelist = ["arisu"];
        permissions = ["rw" "nohide" "insecure" "no_subtree_check" "no_root_squash" "sync"];
      }
    ];
  };

  samba.mounts = {
    "shared" = "arisu";
  };
}
