{inputs, ...}: {
  imports = [
    ../..
    ./hardware-configuration.nix

    inputs.disko.nixosModules.default
    (import ../disko.nix {
      main = "/dev/sda";
      extras = [];
    })
  ];

  networking = {
    hostName = "shiori";
    hostId = "1a4ecbe3";
  };

  httpd.enable = true;

  samba.mounts = {
    "shared" = "arisu";
  };
}
