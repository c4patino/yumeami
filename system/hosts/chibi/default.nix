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

  pm2.enable = true;
}
