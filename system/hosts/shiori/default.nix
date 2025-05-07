{inputs, ...}: {
  imports = [
    ../global.nix
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

  vaultwarden.enable = true;
  grafana.enable = true;

  samba.mounts = {
    "shared" = "arisu";
  };
}
