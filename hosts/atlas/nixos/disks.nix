let
  commonZfsOptions = {
    ashift = "12";
  };
  commonFsOptions = {
    atime = "off";
    xattr = "sa";
    acltype = "posixacl";
    relatime = "on";
    normalization = "formD";
    utf8only = "on";
    "com.sun:auto-snapshot" = "false";
  };
  mediaZfsOptions = {
    recordsize = "1M";
    compression = "off";
  };
  commonEncryptionOptions = {
    encryption = "aes-256-gcm";
    keyformat = "passphrase";
    keylocation = "prompt";
  };
in {
  disko.devices = {
    disk = {
      boot = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Vi3000_SSD_493735318370097";
        name = "boot";
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
        device = "/dev/disk/by-id/nvme-WD_Red_SN700_2000GB_24443X800046";
        name = "ssd1";
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
        device = "/dev/disk/by-id/nvme-WD_Red_SN700_2000GB_25125L800880";
        name = "ssd2";
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
      hdd1 = {
        type = "disk";
        device = "/dev/disk/by-id/wwn-0x50014ee2167a980c";
        name = "hdd1";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zslow_store";
              };
            };
          };
        };
      }; # /hdd1
      hdd2 = {
        type = "disk";
        device = "/dev/disk/by-id/wwn-0x50014ee216c5103a";
        name = "hdd2";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zslow_store";
              };
            };
          };
        };
      }; # /hdd2
      hdd3 = {
        type = "disk";
        device = "/dev/disk/by-id/wwn-0x50014ee26c314a1f";
        name = "hdd3";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zslow_store";
              };
            };
          };
        };
      }; # /hdd3
      hdd4 = {
        type = "disk";
        device = "/dev/disk/by-id/wwn-0x50014ee216c50f6a";
        name = "hdd4";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zslow_store";
              };
            };
          };
        };
      }; # /hdd4
    }; # /disk
    zpool = {
      zroot = {
        type = "zpool";
        rootFsOptions =
          {
            mountpoint = "none";
            compression = "lz4";
          }
          // commonFsOptions;
        options = commonZfsOptions;
        datasets = {
          "root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options = commonEncryptionOptions;
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
        rootFsOptions =
          {
            compression = "lz4";
          }
          // commonFsOptions;
        options = commonZfsOptions;
        datasets = {
          "fast_store" = {
            type = "zfs_fs";
            options = commonEncryptionOptions;
          };
          "fast_store/var_lib" = {
            type = "zfs_fs";
            mountpoint = "/var/lib";
          };
          "fast_store/var_lib/postgresql" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/postgresql";
            options = {
              recordsize = "16K";
            };
          };
          "fast_store/backup" = {
            type = "zfs_fs";
            mountpoint = "/mnt/fast_store/backup";
          };
          "fast_store/misc" = {
            type = "zfs_fs";
            mountpoint = "/mnt/fast_store/misc";
          };
          "fast_store/downloads" = {
            type = "zfs_fs";
            mountpoint = "/mnt/fast_store/downloads";
            options = mediaZfsOptions;
          };
          "fast_store/media" = {
            type = "zfs_fs";
            mountpoint = "/mnt/fast_store/media";
            options = mediaZfsOptions;
          };
        };
      }; # /zfast_store
      zslow_store = {
        type = "zpool";
        mode = {
          topology = {
            type = "topology";
            vdev = [
              {
                mode = "mirror";
                members = ["hdd1" "hdd2"];
              }
              {
                mode = "mirror";
                members = ["hdd3" "hdd4"];
              }
            ];
          };
        };
        rootFsOptions =
          {
            compression = "zstd";
          }
          // commonFsOptions;
        options = commonZfsOptions;
        datasets = {
          "slow_store" = {
            type = "zfs_fs";
            options = commonEncryptionOptions;
          };
          "slow_store/replicas" = {
            type = "zfs_fs";
            mountpoint = "/mnt/slow_store/replicas";
            options.mountpoint = "legacy";
          };
          "slow_store/misc" = {
            type = "zfs_fs";
            mountpoint = "/mnt/slow_store/misc";
            options.mountpoint = "legacy";
          };
          "slow_store/media" = {
            type = "zfs_fs";
            mountpoint = "/mnt/slow_store/media";
            options =
              {
                mountpoint = "legacy";
              }
              // mediaZfsOptions;
          };
        };
      }; # /zslow_store
    }; # /zpool
  };
}
