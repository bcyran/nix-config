{
  disko.devices = {
    disk = {
      boot = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                  "umask=0077"
                ];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      }; # /boot
      ssd1 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zfast_store";
              };
            };
          };
        };
      }; # /ssd1
      ssd2 = {
        type = "disk";
        device = "/dev/nvme2n1";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zfast_store";
              };
            };
          };
        };
      }; # /ssd2
    }; # /disk
    zpool = {
      zroot = {
        type = "zpool";
        rootFsOptions = {
          mountpoint = "none";
          compression = "lz4";
          atime = "off";
          xattr = "sa";
          acltype = "posixacl";
          relatime = "on";
        };
        options.ashift = "12";
        datasets = {
          "root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options = {
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              keylocation = "prompt";
            };
          };
          "root/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options.mountpoint = "/nix";
          };
          "root/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
          };
          "root/var" = {
            type = "zfs_fs";
            mountpoint = "/var";
          };
          "root/swap" = {
            type = "zfs_volume";
            size = "32G";
            content.type = "swap";
            options = {
              volblocksize = "4096";
              compression = "zle";
              logbias = "throughput";
              sync = "always";
              primarycache = "metadata";
              secondarycache = "none";
            };
          };
        };
      }; # /zroot
      zfast_store = {
        type = "zpool";
        mode = "mirror";
        rootFsOptions = {
          compression = "lz4";
        };
        datasets = {
          "fast_store" = {
            type = "zfs_fs";
            options = {
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              keylocation = "prompt";
            };
          };
          "fast_store/var_lib" = {
            type = "zfs_fs";
            mountpoint = "/var/lib";
          };
          "fast_store/backup" = {
            type = "zfs_fs";
            mountpoint = "/mnt/fast_store/backup";
          };
          "fast_store/files" = {
            type = "zfs_fs";
            mountpoint = "/mnt/fast_store/files";
          };
        };
      }; # /zfast_store
    }; # /zpool
  };
}
