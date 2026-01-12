rec {
  # Domains
  domains = rec {
    root = "cyran.dev";
    intra = "intra.${root}";
    extra = "extra.${root}";
    vps = "vps.${root}";
    wg = "wg.${root}";
  };
  # Home LAN
  lan = {
    subnet = "10.100.100.0/24";
    devices = {
      atlas = {
        ip = "10.100.100.100";
        domain = "atlas.${domains.intra}";
      };
      tv = {
        ip = "10.100.100.231";
        domain = "tv.${domains.intra}";
      };
      jetkvm = {
        ip = "10.100.100.101";
        domain = "jetkvm.${domains.intra}";
      };
      flint = {
        ip = "10.100.100.1";
        domain = "flint.${domains.intra}";
      };
    };
  };
  # Wireguard VPN
  wireguard = rec {
    port = 51820;
    endpoint = "${domains.vps}:${toString port}";
    subnet = "10.100.200.0/24";
    subnetv6 = "2a03:4000:52:499:ffff::/80";
    peers = {
      atlas = {
        ip = "10.100.200.100";
        ipv6 = "2a03:4000:52:499:ffff::100";
        domain = "atlas.${domains.wg}";
        publicKey = "hHCFLo07K0hlVbFfRA4Q4iy8qHSusK81732k/Rt2ZCM=";
      };
      vps = {
        ip = "10.100.200.1";
        ipv6 = "2a03:4000:52:499:ffff::1";
        domain = "vps.${domains.wg}";
        publicKey = "8MAr05mDT16BYab0SBG9C8Muulvbibu1osFJTNZzRw8=";
      };
      pixel7 = {
        ip = "10.100.200.2";
        ipv6 = "2a03:4000:52:499:ffff::2";
        domain = "pixel7.${domains.wg}";
        publicKey = "SQIXPzLluN+Ji7s3Wzau59dzlOjebd6TxRbGm8vtDho=";
      };
      slimbook = {
        ip = "10.100.200.3";
        ipv6 = "2a03:4000:52:499:ffff::3";
        domain = "slimbook.${domains.wg}";
        publicKey = "znkXF+4voMh5iCCd68H5gFTFahtfsYTjsCr05Ei/+Tw=";
      };
      jetkvm = {
        ip = "10.100.200.99";
        ipv6 = "2a03:4000:52:499:ffff::99";
        domain = "jetkvm.${domains.wg}";
        publicKey = "bORArI/14BFDU/6HL4tXJLkng0jwZSaF6Me+Myg3BCY=";
      };
    };
  };
  # DNS resolvers
  dns = rec {
    resolvers = [
      {
        https = "https://cloudflare-dns.com/dns-query";
        ips = ["1.1.1.1" "1.0.0.1"];
      }
      {
        https = "https://dns.quad9.net/dns-query";
        ips = ["9.9.9.9" "149.112.112.112"];
      }
      {
        https = "https://dns.mullvad.net/dns-query";
        ips = ["194.242.2.2"];
      }
    ];
    https = map (resolver: resolver.https) resolvers;
    ips = builtins.concatMap (resolver: resolver.ips) resolvers;
  };
  # Public SSH keys
  sshKeys = {
    bazyliAtSlimbook = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFKs3m56bDR5P7TXoL/MPd5FWyueqK3QPVGc7RwLnF09 bazyli@slimbook";
    btrbkAtSlimbook = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC8a552vyvnPoS/JEkSujoygzQw0cB8jO2yI8VlsLUF6 btrbk@slimbook";
    bazyliAtPixel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGz5erZsix4olGmCQreNBjirZUXJihOWbvGdd27SeX+7 bazyli@pixel";
  };
  # Syncthing
  syncthing = {
    devices = {
      slimbook = "ADH7KVP-ATNX6XY-VSBFKEW-U7A4TAI-2YA6JQG-DZHNGRR-2DZOIXW-KAS6AQX";
      pixel7 = "WCA3ZM5-ZELYQWF-VAWS425-OPG5Q4R-O4J3ARM-IOPGI7Z-BTE2TY5-EZ36AAI";
      atlas = "3Z4EMEX-FDR6OGT-KYTYFCO-TDANTYU-4NLDGDG-HOGFV7Q-MXWI75O-N67EDQG";
    };
  };
  # Nix binary cache public keys
  binaryCacheKeys = {
    slimbook = "slimbook:jM8DwCMIrEPhbPqKLXhJ7niRN3kIxRitj3pT7Q5575o=";
    intra = "cache.intra.cyran.dev:+E/2B6YJdSqCdOmMfw8GmyPBf4Fl63t4RdIwoMBuLBk";
  };
  # Filesystem paths
  paths = {
    atlas = rec {
      slowStore = "/mnt/slow_store";
      fastStore = "/mnt/fast_store";
      slowMedia = "${slowStore}/media";
      fastMedia = "${fastStore}/media";
      backup = "${fastStore}/backup";
      replicas = "${slowStore}/replicas";
      downloads = "${fastStore}/downloads";
      slowMisc = "${slowStore}/misc";
      fastMisc = "${fastStore}/misc";
    };
  };
}
