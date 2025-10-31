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
      };
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
    }; # /zpool
  };
}
