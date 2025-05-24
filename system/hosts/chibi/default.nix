{inputs, ...}: {
  imports = [
    ../global.nix
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
  uptime-kuma.enable = true;

  blocky.enable = true;
  httpd.enable = true;
  unbound.enable = true;

  gitea-runners = {
    enable = true;
    runners."default" = {instances = 5;};
  };

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
