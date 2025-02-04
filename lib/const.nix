rec {
  # Domains
  domains = rec {
    root = "cyran.dev";
    homelab = "intra.${root}";
    vps = "vps.${root}";
  };
  # Home LAN
  lan = {
    subnet = "10.100.100.0/24";
    devices = {
      homelab = {
        ip = "10.100.100.100";
      };
      tv = {
        ip = "10.100.100.231";
      };
    };
  };
  # Wireguard VPN
  wg = rec {
    port = 51820;
    endpoint = "${domains.vps}:${toString port}";
    subnet = "10.100.200.0/24";
    peers = {
      homelab = {
        ip = "10.100.200.100";
        publicKey = "hHCFLo07K0hlVbFfRA4Q4iy8qHSusK81732k/Rt2ZCM=";
      };
      vps = {
        ip = "10.100.200.1";
        publicKey = "8MAr05mDT16BYab0SBG9C8Muulvbibu1osFJTNZzRw8=";
      };
      pixel7 = {
        ip = "10.100.200.2";
        publicKey = "SQIXPzLluN+Ji7s3Wzau59dzlOjebd6TxRbGm8vtDho=";
      };
      slimbook = {
        ip = "10.100.200.3";
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
    ];
    https = map (resolver: resolver.https) resolvers;
    ips = builtins.concatMap (resolver: resolver.ips) resolvers;
  };
}
