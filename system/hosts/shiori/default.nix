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
  forgejo.enable = true;

  gitea-runners = {
    enable = true;
    runners."default" = {instances = 5;};
  };

  samba.mounts = {
    "shared" = "arisu";
  };
}
