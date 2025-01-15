{device ? throw "Storage device not defined", ...}: {
  disko.devices = {
    disk.main = {
      inherit device;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "3M";
            type = "EF02";
          };
          esp = {
            name = "ESP";
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot/efi";
            };
          };
          swap = {
            size = "32G";
            content = {
              type = "swap";
              resumeDevice = true;
            };
          };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "zfs";
              pool = "zroot";
            };
          };
        };
      };
    };
    zpool = {
      zpool = {
        type = "zpool";
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
        };

        datasets = {
          root = {
            type = "zfs_fs";
            options = {
              mountpoint = "/";
              relatime = "on";
            };
          };
          persist = {
            type = "zfs_fs";
            options = {
              mountpoint = "/persist";
              relatime = "on";
            };
          };
          nix = {
            type = "zfs_fs";
            options = {
              mountpoint = "/nix";
              atime = "off";
            };
          };
        };
      };
    };
  };
}
