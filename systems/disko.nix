{
  main ? throw "Primary device not defined",
  extras ? [],
  pools ? [],
  size ? "100%",
  ...
}: let
  mainDisk = {
    main = {
      device = main;
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
              mountpoint = "/boot";
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
            size = size;
            content = {
              type = "zfs";
              pool = "zroot";
            };
          };
        };
      };
    };
  };

  extraDisks = builtins.listToAttrs (map (d: {
      name = d;
      value = {
        device = d;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
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
    })
    extras);

  poolDiskEntries = builtins.concatLists (map (
      pool:
        map (disk: {
          inherit disk;
          poolName = pool.name;
        })
        pool.disks
    )
    pools);

  poolDisks = builtins.listToAttrs (map (entry: {
      name = entry.disk;
      value = {
        device = entry.disk;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            root = {
              name = "root";
              size = "100%";
              content = {
                type = "zfs";
                pool = entry.poolName;
              };
            };
          };
        };
      };
    })
    poolDiskEntries);

  poolConfigs = builtins.listToAttrs (map (pool: {
      name = pool.name;
      value = {
        type = "zpool";
        mode = pool.type;
        rootFsOptions = {
          compression = "zstd";
          canmount = "off";
          "com.sun:auto-snapshot" = "false";
        };
        datasets = builtins.listToAttrs (map (dsName: {
            name = dsName;
            value = {
              type = "zfs_fs";
              mountpoint = pool.datasets.${dsName}.mountpoint or null;
              options = pool.datasets.${dsName}.options or {};
            };
          })
          (builtins.attrNames pool.datasets));
      };
    })
    pools);
in {
  disko.devices = {
    disk = mainDisk // extraDisks // poolDisks;
    zpool =
      {
        zroot = {
          type = "zpool";
          rootFsOptions = {
            compression = "zstd";
            canmount = "off";
            "com.sun:auto-snapshot" = "false";
          };

          datasets = {
            root = {
              type = "zfs_fs";
              mountpoint = "/";
              options = {
                relatime = "on";
              };
            };
            persist = {
              type = "zfs_fs";
              mountpoint = "/persist";
              options = {
                mountpoint = "legacy";
                relatime = "on";
              };
            };
            nix = {
              type = "zfs_fs";
              mountpoint = "/nix";
              options = {
                atime = "off";
              };
            };
          };
        };
      }
      // poolConfigs;
  };
}
