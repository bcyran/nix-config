let
  commonBtrfsMountOptions = [
    "defaults"
    "compress=zstd:1"
    "noatime"
    "nodiratime"
  ];
  ssdBtrfsMountOptions =
    commonBtrfsMountOptions
    ++ [
      "ssd"
      "discard=async"
    ];
  hddBtrfsMountOptions = commonBtrfsMountOptions;
in {
  disko.devices = {
    disk = {
      root = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Vi3000_SSD_493735318370097";
        name = "root";
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
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "root_crypt";
                settings = {
                  allowDiscards = true;
                  bypassWorkqueues = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];
                  subvolumes = {
                    "@" = {
                      mountpoint = "/";
                      mountOptions = ssdBtrfsMountOptions;
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = ssdBtrfsMountOptions;
                    };
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = ssdBtrfsMountOptions;
                    };
                    "@var" = {
                      mountpoint = "/var";
                      mountOptions = ssdBtrfsMountOptions;
                    };
                    "@snapshots" = {
                      mountpoint = "/.snapshots";
                      mountOptions = ssdBtrfsMountOptions;
                    };
                    "@swap" = {
                      mountpoint = "/.swap";
                      mountOptions = ["defaults" "noatime" "nodatacow"];
                      swap.swapfile.size = "32G";
                    };
                  };
                };
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
            mdadm = {
              size = "100%";
              content = {
                type = "mdraid";
                name = "fast_store";
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
            mdadm = {
              size = "100%";
              content = {
                type = "mdraid";
                name = "fast_store";
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
            mdadm = {
              size = "100%";
              content = {
                type = "mdraid";
                name = "slow_store";
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
            mdadm = {
              size = "100%";
              content = {
                type = "mdraid";
                name = "slow_store";
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
            mdadm = {
              size = "100%";
              content = {
                type = "mdraid";
                name = "slow_store";
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
            mdadm = {
              size = "100%";
              content = {
                type = "mdraid";
                name = "slow_store";
              };
            };
          };
        };
      }; # /hdd4
    }; # /disk
    mdadm = {
      fast_store = {
        type = "mdadm";
        name = "fast_store";
        level = 1;
        content = {
          type = "gpt";
          partitions = {
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "fast_store_crypt";
                settings = {
                  allowDiscards = true;
                  bypassWorkqueues = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];
                  subvolumes = {
                    "@fast_store" = {
                      mountpoint = "/mnt/fast_store";
                      mountOptions = ssdBtrfsMountOptions;
                    };
                    "@fast_store/var_lib" = {
                      mountpoint = "/var/lib";
                      mountOptions = ssdBtrfsMountOptions;
                    };
                    "@fast_store/backup" = {};
                    "@fast_store/downloads" = {};
                    "@fast_store/media" = {};
                    "@fast_store/misc" = {};
                  };
                };
              };
            };
          };
        };
      }; # /fast_store
      slow_store = {
        type = "mdadm";
        name = "slow_store";
        level = 10;
        content = {
          type = "gpt";
          partitions = {
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "slow_store_crypt";
                settings = {
                  bypassWorkqueues = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];
                  subvolumes = {
                    "@slow_store" = {
                      mountpoint = "/mnt/slow_store";
                      mountOptions = hddBtrfsMountOptions;
                    };
                    "@slow_store/media" = {};
                    "@slow_store/backup" = {};
                    "@slow_store/misc" = {};
                  };
                };
              };
            };
          };
        };
      }; # /slow_store
    }; # /mdadm
  };
}
