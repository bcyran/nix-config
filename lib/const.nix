rec {
  # Domains
  domains = rec {
    root = "cyran.dev";
    intra = "intra.${root}";
    vps = "vps.${root}";
    wg = "wg.${root}";
  };
  # Home LAN
  lan = {
    subnet = "10.100.100.0/24";
    devices = {
      homelab = {
        ip = "10.100.100.100";
        domain = "homelab.${domains.intra}";
      };
      tv = {
        ip = "10.100.100.231";
        domain = "tv.${domains.intra}";
      };
    };
  };
  # Wireguard VPN
  wireguard = rec {
    port = 51820;
    endpoint = "${domains.vps}:${toString port}";
    subnet = "10.100.200.0/24";
    peers = {
      homelab = {
        ip = "10.100.200.100";
        domain = "homelab.${domains.wg}";
        publicKey = "hHCFLo07K0hlVbFfRA4Q4iy8qHSusK81732k/Rt2ZCM=";
      };
      vps = {
        ip = "10.100.200.1";
        domain = "vps.${domains.wg}";
        publicKey = "8MAr05mDT16BYab0SBG9C8Muulvbibu1osFJTNZzRw8=";
      };
      pixel7 = {
        ip = "10.100.200.2";
        domain = "pixel7.${domains.wg}";
        publicKey = "SQIXPzLluN+Ji7s3Wzau59dzlOjebd6TxRbGm8vtDho=";
      };
      slimbook = {
        ip = "10.100.200.3";
        domain = "slimbook.${domains.wg}";
        publicKey = "znkXF+4voMh5iCCd68H5gFTFahtfsYTjsCr05Ei/+Tw=";
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
  };
}
